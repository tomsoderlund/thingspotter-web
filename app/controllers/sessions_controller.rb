class SessionsController < ApplicationController
  
  def new
    set_page_title 'Log In'
  end

  def create
  end

  def destroy
    #clear_fb_cookies!
    #clear_facebook_session_information
    session[:current_user_id] = nil
    reset_session # remove your cookies!
    flash[:notice] = "You have been logged out."
    redirect_to root_url
  end

end