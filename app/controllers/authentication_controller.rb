require 'openid'
require 'ar_openid_store'

class AuthenticationController < ApplicationController
  protect_from_forgery :except => [:begin_openid_auth]

  def login
    #if a prev request already exists don't overwrite it
    if !has_prev_request?
      save_prev_request( request )
    end
  end

  def logout
    if logged_in?
      flash[:notice] = 'good bye ' + user
      logout_user
    else
      flash[:notice] = 'good bye'  
    end

    #redirect_to :controller => 'lists'
    if request.referer
      redirect_to request.referer 
    else
      redirect_to "/"
    end
  end

  def begin_openid_auth
    begin
      identifier = params[:openid_identifier]
      if identifier.nil?
        flash[:error] = "Enter an OpenID identifier"
        redirect_to :action => 'index'
        return
      end
      oidreq = consumer.begin(identifier)
    rescue OpenID::OpenIDError => e
      flash[:error] = "Discovery failed for #{identifier}: #{e}"
      redirect_to :action => 'index'
      return
    end

    return_to = url_for :action => :finish_openid_auth, :only_path => false
    realm = url_for :action => 'index', :only_path => false
    
    if oidreq.send_redirect?(realm, return_to)
      redirect_to oidreq.redirect_url(realm, return_to)
    else
      render :text => oidreq.html_markup(realm, return_to, {'id' => 'openid_form'})
    end
  end


  def finish_openid_auth
    current_url = url_for(:action => :finish_openid_auth, :only_path => false)
    parameters = params.reject{|k,v|request.path_parameters[k]}
    oidresp = consumer.complete(parameters, current_url)
    case oidresp.status
    when OpenID::Consumer::SUCCESS
    
      user = User.find(:first, :conditions => { :user_openid => oidresp.identity_url})
      if user
        session[:user] = user.user
        flash[:notice] = "welcome back " + user.user
      else
        session[:user_openid] = oidresp.identity_url
        redirect_to :controller => :users, :action => :new
        return
      end

    when OpenID::Consumer::FAILURE
      if oidresp.identity_url
        flash[:error] = ("Verification of #{oidresp.identity_url}"\
                         " failed: #{oidresp.message}")
      else
        flash[:error] = "Verification failed: #{oidresp.message}"
      end
    when OpenID::Consumer::SETUP_NEEDED
      flash[:error] = "Immediate request failed - Setup Needed"
    when OpenID::Consumer::CANCEL
      flash[:error] = "OpenID transaction cancelled."
    end
    redirect_to_org_request
  end

  private

  def consumer
    if @consumer.nil?
      store = ActiveRecordStore.new()
      @consumer = OpenID::Consumer.new(session, store)
    end
    return @consumer
  end

end
