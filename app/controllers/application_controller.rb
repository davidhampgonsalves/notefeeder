# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  #returns false if user is not logged in
  #and redirects to the login page. true otherwise  
  def login_required
    #check if the user is logged in
    if session[:user]
      return true
    end

    #user is not logged in, save the original request
    save_org_request( request )

    #if the user was included in the request pass it along to the login controller 
    #redirect to login page
    redirect_to :controller => :authentication, :action => :login
    return false
  end

  #saves the original request based 
  def save_org_request( request )
    session[:org_request_uri] = request.url
    session[:org_request_method] = request.request_method
    session[:org_request_params] = request.params
  end

  #saves the previous request based on the referer 
  def save_prev_request( request )
    if request.referer
      session[:org_request_uri] = request.referer
      session[:org_request_method] = :get
    end
  end

  def has_prev_request?
    return session[:org_request_uri] != nil
  end

  def logged_in?
    if session[:user]
      return true
    else
      return false
    end
  end

  #returns the current user (name)
  def user
    session[:user]
  end

  def login_user(user)
    session[:user] = user
  end

  def logout_user
    #clear out the users session
    session[:user] = nil
    session[:user_lists] = nil
    session[:deleted_user_lists] = nil
  end

  #returns the users lists hash from the session if it exists
  def user_lists
    session[:user_lists]
  end

  #returns the users lists hash from the session if it exists
  def deleted_user_lists
    session[:deleted_user_lists]
  end

  #redirects the user to the orginally requested uri
  def redirect_to_org_request
    #redirect to either the org uri or if its a post request 
    #then simulate the post request on the server side and redirect
    if org_request = session[:org_request_uri]
      logger.debug('>>>>>>>>>>> ' + session[:org_request_uri])
      if session[:org_request_method] == :get
        redirect_to org_request
      else
        redirect_post session[:org_request_params]
      end
    else
      redirect_to :controller => :lists
    end

    #clear the org request
    session[:org_request_uri] = nil
    session[:org_request_method] = nil
    session[:org_request_params] = nil
  end

  #this was taken from: http://web.archive.org/web/20080605121920/http://last10percent.com/2008/05/26/post-redirects-in-rails/
  #it handles redirecting post requests after the user has logged in
  def redirect_post(params)
    controller_name = params[:controller]
    controller = (controller_name.camelize + 'Controller').constantize
    # Throw out existing params and merge the stored ones
    request.parameters.reject! { true }
    request.parameters.merge!(params)
    controller.process(request, response)

    if response.redirected_to
      @performed_redirect = true
    else
      @performed_render = true
    end
  end

  #returns if the user lists have been cached
  def user_lists_cached?
    if user_lists != nil
      return true
    else
      return false
    end
  end

  helper_method :conditional_cache
  def conditional_cache(condition,key, &block)
    if condition and cache_configured?
      cached = cache_store.read(ActiveSupport::Cache.expand_cache_key(key, :controller))
      render :inline => cached
   else
      yield
   end
  end

  def expire_cached_lists(list_id)
     #clear the cached lists show actions for both html and rss formats
    expire_fragment(:controller => :lists, :action => :show, :id => list_id, :page => 0, :action_suffix => 'list_notes')
    expire_action :controller => :lists, :action => :show, :id => list_id, :format => :rss
  end

  #overrides the default error form validation injection to insert a span with class field_with_error
  #instead of the standard div
  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    "<span class='field_with_error'>" + html_tag + "</span>"
  end
end
