# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'lib/facebook_user'; include FacebookUser
require 'lib/thingspotter_lib'; include ThingspotterLib

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  #before_filter :force_current_user
  before_filter :set_page_title
  before_filter :parse_facebook_signed_request
  before_filter :preload_activator_box
  #before_filter :load_welcome_new_user_info
  #before_filter :set_facebook_session
  #before_filter :set_facebook_session_key
  
  helper_method :logged_in?, :current_user, :has_site_access?, :detect_browser, :is_admin?, :can_edit_thing?
  
  #rescue_from Facebooker::Session::SessionExpired, :with => :facebook_session_expired

  layout :select_layout # 'desktop' # :detect_browser 


  private
  
  def set_page_title(title = nil, use_template = true)
    if title.nil?
      use_default_title = true
      title = self.controller_name.gsub('_', ' ').titleize
    end
    if (use_default_title || use_template)
      @page_title = "#{title} on Thingspotter"
      @page_description = "#{title} on Thingspotter."
      @page_reference = self.controller_name.downcase
    else
      @page_title = title
      @page_description = title
      @page_reference = title.downcase
    end
    @page_keywords = "Thingspotter,products,shopping," + title
  end  

  def select_layout
    session.inspect # Force session load
    if params[:device]
      return session['layout'] = params[:device]
    elsif session.has_key?('layout')
      return (session['layout'] == 'mobile') ? 'mobile' : 'desktop'
    end
    # If not in Session, look it up
    return session['layout'] = detect_browser
  end

  def detect_browser
    mobile_browsers = ['iphone', 'ipod', 'android', 'windows phone'] # 'ipad',
    user_agent = request.headers["HTTP_USER_AGENT"].downcase
    mobile_browsers.each do |browser_name|
      return 'mobile' if user_agent.match(browser_name)
    end
    return 'desktop'
  end
  
  def preload_activator_box
    if current_user
      case 1 #rand(2)
        when 0: # Related user
          user_list = current_user.related_users
          @related_user = user_list[rand(user_list.size)]
        else # User to invite
          user_list = current_user.find_friend_users_not_on_thingspotter('users.fb_user_id')
          @user_to_invite = user_list[rand(user_list.size)]
      end
    end
  end
  
  def load_welcome_new_user_info
    if !current_user
      @welcome_new_user_text = Page.find_by_permalink('welcome_new_user').body
      #@welcome_new_user_text = "Welcome New User!"
    end
  end
  
  def force_current_user
    current_user = User.first
  end

  def has_site_access?
    # Not logged in + wrong password? Go away!
    #params[:access_code] != 'my_precious'
    
    # INVITE BEHAVIOR: change here
    return true
    
    # if (current_user) && current_user.invitation)
    #   return true
    # else
    #   return false
    # end
  end

  def check_if_has_site_access(do_redirect = true)
    #logger.debug 'check_if_has_site_access'
    
    if !has_site_access?
      @beta_text = Page.find_by_permalink('beta').body
      @beta_invitation = Invitation.new
      if do_redirect
        set_page_title 'Thingspotter Beta', false
        @show_social_media = true
        @page_tracking_path = '/beta'
        #redirect_to '/beta'
        render :template => 'errors/no_beta_access.html.erb', :layout => 'limited'
      end
      return false
    end
    return true
  end

  def is_admin?
    if (current_user.nil? || !current_user.is_admin)
      return false
    else
      return true
    end
  end

  def check_if_admin_access
    if !is_admin?
      render :template => 'errors/no_access.html.erb'
      return false
    end
    return true
  end
  
  def can_edit_user?(userref)
    return current_user && (is_admin? || userref == current_user)
  end
  
  def check_if_can_edit_user(userref)
    if can_edit_user?(userref)
      return true
    end
    render :template => 'errors/no_access.html.erb'
    return false
  end

  def can_edit_thing?(thing_ref)
    return current_user && (is_admin? || thing_ref.user == current_user)
  end
  
  # Get date range values
  def date_range
    date_start = Date.new(Date.today.year, Date.today.month, 1)
    date_end = Date.new(date_start.year, (date_start.month+1), 1)
    if params[:start]
      date_start = Date.parse(params[:start])
      date_end = Date.new(date_start.year, (date_start.month+1), 1)
    end
    date_end = Date.parse(params[:end]) if params[:end]
    #logger.debug "Date range: " + date_start.strftime("%B %Y") + " -> " + date_end.strftime("%B %Y")
    return {:start => date_start, :end => date_end}
  end
     
end