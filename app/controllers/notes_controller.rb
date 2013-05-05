require 'cached_list'

class NotesController < ApplicationController
  before_filter :login_required, :except => [:show, :create_from_bookmark]
  before_filter :init_session_user_lists
  protect_from_forgery :except => [:create]
  include CachedList

  # GET /notes/1
  def show
    @note = Note.find(params[:id])

    if @note.is_private
      if user
        if not get_cached_list_info(@note.list_id)
          flash[:notice] = 'sorry, that note is someone else\'s and they don\'t want you to see it'
          redirect_to :controller => :lists
        end
      else
        #if this is a private note the user needs to be loged in to see it
        login_required
      end
    end
  end

  # GET /notes/search
  def search
    search_term = params[:s]
    @page = params.key?(:page) ? params[:page].to_i : 0
    if search_term != nil
      search_term =  search_term.gsub('%', '\%').gsub('_', '\_')
      list_ids = []
      user_lists.each_value do | list |
        list_ids.push(list[:id])
      end
      @notes = Note.all(:conditions=> ["to_tsvector('english', title || ' ' || url || ' ' || description) @@ to_tsquery(?) and list_id in (?)", search_term, list_ids], :limit => 16, :offset => @page * (16 - 1), :order => 'id desc')
    else
      @notes = {}
    end
  end

  # GET /notes/new
  def new
    @note = Note.new
    build_notes_list_field

    render :action => "edit"
  end

  # GET /notes/1/edit
  def edit
    @note = Note.find(params[:id])

    @list_name_ids = {}
    user_lists.each_value do | list |
      @list_name_ids[list[:name]] = list[:id]
    end

    #check that the note exists
    if not does_user_own? @note
        flash[:error] = "You can only edit your own notes"
        redirect_to :action => :show, :id => params[:id]
    elsif not @note
      flash[:error] = "that note wasn't found"
    else
      flash[:org_request] = request.referer
    end
  end

  # GET /notes/1/delete
  def delete
    @note = Note.find(params[:id])

    @list_name_ids = {}
    user_lists.each_value do | list |
      @list_name_ids[list[:name]] = list[:id]
    end

    #check that the note exists
    if not does_user_own? @note
        flash[:error] = "You can only delete your own notes"
        redirect_to :action => :show, :id => params[:id]
    elsif not @note
      flash[:error] = "that note wasn't found"
    end
  end

  # POST /notes
  #calls the create note and handles redirects for errors and success
  def create
    status = create_note()

    if status.key? :success
      flash[:notice] = status[:success]
      redirect_to :controller => :lists, :action => :show, :id => @note.list_id      
    elsif status.key? :error
      error =  status[:error]
      if error.key? :permissions
        flash[:error] = error[:permissions]
        redirect_to :controller => :lists
      end
    else
      build_notes_list_field()
      render :action => :edit
    end
     
  end

  #need to create from bookmarks 
  def create_from_bookmark
    status = {}
    #check that the user is logged in
    if not logged_in?
      status[:error] = {:auth => 'need to login'}
    else
      status = create_note()
    end

    #make the json response jsonp by adding the callback name
    if params.key? :callback
      status = "#{params[:callback]}(#{status.to_json});"
    else  
      status = "callback(#{status.to_json});"
    end

    render({:content_type => :js, :text => status})
  end


  #marks a note as completed(strike through, and doesn't show it in RSS feed)
  def complete
    @note = Note.find(params[:id])
    logger.debug('>> ' + request.referer)
    #check that the user owns this list
    if does_user_own? @note
      @note.completed = true
      if @note.save
        #clear the cached list if appliciable
        expire_cached_lists @note.list_id
        #redirect back to the last page if possiable or to the notes list
        if request.referer != nil
          redirect_to request.referer
        else
          redirect_to :controller => :lists, :action => :show, :id => @note.list_id
        end
      else
        flash[:error] = 'there was an error, this note couldn\'t be altered'
        render :action => "show", :id => @note.id
      end
    else
        #if note isn't nil then the user is trying to edit someone elses notes
        if @note
          flash[:error] = 'note couldn\'t be found'
        else
          flash[:error] = 'you can\'t edit notes that you don\'t own'
        end
        redirect_to :controller => 'lists'
    end
  end

  # PUT /notes/1
  # PUT /notes/1.xml
  def update
    @note = Note.find(params[:id])

    #check that the user owns this list
    if does_user_own? @note
      org_list_id = params[:note][:list_id]
      if @note.update_attributes(params[:note])
        flash[:notice] = 'Note was successfully updated.'
        #clear the cached list if appliciable
        expire_cached_lists @note.list_id
        #clear the original list if this change altered the 
        #notes assoicated list
        if org_list_id != @note.list_id
          expire_cached_lists org_list_id
        end
        
        if flash.key? :org_request
          redirect_to flash[:org_request]
        else
          redirect_to :controller => :lists, :action => :show, :id => @note.list_id
        end
      else
        render :action => "edit"
      end
    else
        #if note isn't nil then the user is trying to edit someone elses notes
        if @note
          flash[:error] = 'note couldn\'t be found'
        else
          flash[:error] = 'you can\'t edit notes that you don\'t own'
        end
        redirect_to :controller => 'lists'
    end
  end

  # DELETE /notes/1
  def destroy
    @note = Note.find(params[:id])

    #check that the user owns this list first
    if does_user_own? @note
      @note.list_id
      @note.destroy
      flash[:notice] = 'note successfully removed'
      #clear the cached list if appliciable
      expire_cached_lists @note.list_id
    else
      flash[:error] = 'you can\'t delete notes you don\'t own'
    end
    redirect_to :controller => :lists, :action => :show, :id => @note.list_id
  end

  private
    def build_notes_list_field
      @list_name_ids = {}
      user_lists.each_value do | list |
        @list_name_ids[list[:name]] = list[:id]
      end

      #get the selected list name
      if list_id = params[:list_id]
        @list_id = list_id
      end
    end
    
    def create_note
      status = {}
      #create the note from the params in one of two ways: from a form, from the get params
      if params.has_key? :note
        @note = Note.new(params[:note])
      else
        #if the form wasn't submitted by the form set the parameters individually
        #also remove encoding from title and description
        @note = Note.new()
        @note.list_id = params[:list_id]
        @note.title = !params[:title].nil? ? CGI::unescape(params[:title]) : ''
        @note.description = !params[:description].nil? ? CGI::unescape(params[:description]) : ''
        @note.url = !params[:url].nil? ? params[:url] : ''
      end

      #check if the user owns this list
      if does_user_own? @note
        if not @note.title or @note.title.empty?
          #set the title using the url or description if not set
          if @note.url and not @note.url.empty?
            @note.title = @note.url[0..255]
          elsif @note.description and not @note.description.empty?
            @note.title = @note.description[0..255]
          end
        end

        if @note.save
          status[:success] = 'Note was successfully created.'
          #clear the cached list if appliciable
          expire_cached_lists @note.list_id
        end
      else
        status[:error] = {:permissions => 'you can\'t add notes to lists you don\'t own'}
      end

      return status
    end


    #returns true if the user owns the note passed in
    def does_user_own?(note)
      if note and get_cached_list_info(note.list_id)
        return true
      else
        return false
      end 
    end
end
