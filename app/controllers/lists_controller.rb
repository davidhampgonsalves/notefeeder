require 'cached_list'

class ListsController < ApplicationController
  before_filter :login_required, :except => [:show, :show_by_name]
  before_filter :init_session_user_lists, :except => [:show, :show_by_name]
  caches_action :show, :format => :rss, :expires_in => 1.day, :if => Proc.new { |c| ((!c.request.params.key? :page or c.request.params[:page].to_i == 0) and c.request.format.rss?) }  
  protect_from_forgery :except => [:create]
  caches_page :new
  helper :notes
  include CachedList

  # GET /lists
  def index
    #use the user lists session hash to create the index page
    @user = user
    @lists = user_lists
    @deleted_lists = deleted_user_lists
  end

  #GET /lists/show
  def show
    list_id = params[:id].to_i

    @list = nil
    #if the user_lists are stored in the cache then get the name of this list
    if user_lists_cached?
      @list = get_cached_list_info(list_id)
    end

    if !@list
      @list = List.find(list_id, :conditions => {:deleted => false}) 
    end

    if not @list
      flash[:error] = "a list with id #{list_id} wasn't found"
      redirect_to :controller => :errors  
    else
      respond_to do | format |
        format.html do
          @page = params.key?(:page) ? params[:page].to_i : 0
          unless fragment_exist?(:controller => :lists, :action => :show, :id => @list[:id], :page => @page, :action_suffix => 'list_notes')
            #get one more record so we know if we should have paging links          
            @notes = Note.all(:conditions => { :list_id => @list[:id] }, :limit => 16, :offset => @page * (16 - 1), :order => 'id desc')
          end
        end
        format.rss do
          @notes = Note.all(:conditions => {:list_id => @list[:id], :completed => false}, :limit => 25, :order => 'id desc')
          render :layout => false
        end
      end
    end  
  end

  #GET /lists/show_by_name
  def show_by_name
    #use the default list if a list name wasn't spesified
    if params.key? :list_name
      list_name = URI.unescape(params[:list_name])
    else
      list_name = 'default'
    end

    #if the user_lists has been initilized and the request if for this user 
    #use that instead of going to the database
    if user_lists_cached? and URI.unescape(params[:user]) == user
      @list = user_lists[list_name]
      #if this list dosn't have a public url then they can't access it this way
      if not @list.nil? and not @list[:has_public_url]
        @list = nil
      end
    end

    #if the user lists wasn't found in the users cache then query the database
    if @list.nil?
      @list = List.find(:first, :conditions => { :user => params[:user], :name => list_name, :has_public_url => true})
      unless @list.nil?
        @list = create_list_hash(@list)
      end
    end    

    #if the list isn't nil then call show using its id
    unless @list.nil?
      params[:id] = @list[:id]
      show()
      render :show
    else
      flash[:error] = "The list '#{list_name}' wasn't found"
      redirect_to :controller => 'errors'    
    end
  end

  # GET /lists/new
  def new
    @list = List.new
    @list.has_public_url = true
  end

  # GET /lists/1/edit
  def edit
    @list = List.find(params[:id], :conditions => { :user => user})
  end

  # POST /lists
  def create
    @list = List.new(params[:list])
    #set the current user as the lists user 
    @list.user = user


    if @list.save
      flash[:notice] = 'list was successfully created.'
      flash[:warning] = 'recreate the bookmarklet to update it.'
      
      #if the session contains the users list of lists then add this new list
      if user_lists
        user_lists[@list.name] = create_list_hash(@list)
      end

      redirect_to :controller => :lists
    else
      render :action => :new, :list_id => @list[:id]
    end
  end

  # PUT /lists/1
  def update
    @list = List.find(params[:id], :conditions => { :user => user})

    org_name = @list.name

    #make sure the user isn't trying to change the name of the default list
    if org_name == "default" and params[:list][:name]
      params[:list][:name] = org_name
    end    

    if @list.update_attributes(params[:list])
      #update the active record with the new name
      flash[:notice] = "the list '#{@list.name}' was successfully updated"
      #clear the cached list if appliciable
      expire_cached_lists @list.id

      #if the session contains the users list of lists then make the change there too
      if logged_in?
        #remove the old entry
        user_lists.delete(org_name)
        #add the list entry with its new name
        user_lists[@list.name] = create_list_hash(@list)
      end

      redirect_to :controller => :lists
    else
      render :action => "edit"
    end

  end

  # DELETE /lists/1
  def delete
    @list = List.find(params[:id], :conditions => { :user => user})
    
    if @list.name == 'default'
      flash[:error] = 'you can\'t delete the default list'
      redirect_to(lists_url)   
    end

    #mark list as deleted
    @list.update_attributes :deleted => true, :deleted_since => Time.now, :has_public_url => false

    #clear the cached list if appliciable
    expire_cached_lists @list.id

    #if the user lists exists delete this lists name from it
    if(user_lists)
      #add it to the users deleted lists
      deleted_user_lists[@list.name] = user_lists[@list.name]
      #delete the list from the session      
      user_lists.delete @list.name
    end

    respond_to do |format|
      format.html { redirect_to(lists_url) }
    end
  end

  # get /lists/undelete/1
  def undelete
    @list = List.find(params[:id], :conditions => { :user => user})

    #if the user lists exists delete this list entry from it
    if(user_lists)
      #add it to the users lists
      user_lists[@list.name] = deleted_user_lists[@list.name]
      #delete the list from the users deleted lists
      deleted_user_lists.delete @list.name
    end

    #mark list as deleted
    @list.update_attributes :deleted => false

    #clear the cached list if appliciable
    expire_cached_lists @list.id

    respond_to do |format|
      format.html { redirect_to(lists_url) }
    end
  end
end
