class UsersController < ApplicationController
  layout 'authentication'
  def new
      #if the users open id identifier isn't set then send them back to login
     if not session[:user_openid]
      redirect_to :controller => :authentication, :action => :login
    else
      @user = User.new    
    end    
  end

  def create
    if not session[:user_openid]
      redirect_to :controller => :login
    end

    @user = User.new(params[:user])
    @user.user_openid = session[:user_openid]

    if @user.save
        flash[:notice] = 'welcome to note feeder ' + @user.user
        flash[:warning] = 'the bookmarklet is the easiest way to save urls and notes, check it out bellow'
        flash[:highlight_bookmarklet] = true
        
        #log this user in
        login_user @user.user

        #create the default list for this user
        default_list = List.new(:user => @user.user, :name => 'default')
        default_list.save
        
        redirect_to :controller => :lists
    else
      render :action => "new"
    end
  end

  def is_available
    user_name = params[:user_name]    
    msg = {}

    if user_name and user_name.strip != ''
      user = User.find(:first, :conditions => {:user => user_name})
      if user
        msg[:available] = false;
        msg[:msg] = 'that username is already taken.'
      else
        msg[:available] = true;
        msg[:msg] = 'yes, that is available'
      end
    else
      msg[:available] = false;
      msg[:msg] = 'you can\'t have a blank user name'
    end

    render :json => msg
  end
end
