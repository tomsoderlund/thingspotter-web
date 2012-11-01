# NOTE: Methods for Controllers and Models, not only Views
# Include with:
# require 'lib/facebook_user'; include FacebookUser

module FacebookUser

  def logged_in?
    #logger.debug 'current_user: ' + current_user.to_s
    return !current_user.nil?
  end

  def current_user
    return User.find($FORCE_CURRENT_USER_ID) if $FORCE_CURRENT_USER_ID
    
    begin
      @current_user = User.find(session[:current_user_id]) if session[:current_user_id]
    rescue
    end
    @current_user = (login_from_facebook_session) if @current_user.nil?
    return @current_user
  end

  def get_facebook_graph
    # Koala/Facebook SSL - #TODO: refactor to only use in koala.rb
    if (Rails.env.production? || Rails.env.staging?)
      Koala.http_service.http_options = {
        :ssl => {
          :ca_path => '/etc/ssl/certs',
          :verify_mode => OpenSSL::SSL::VERIFY_PEER,
          :verify => true
        }
      }
    end
    
    @facebook_cookies = Koala::Facebook::OAuth.new.get_user_info_from_cookie(cookies)
    if @facebook_cookies
      oauth_access_token = @facebook_cookies["access_token"]
      graph = Koala::Facebook::GraphAPI.new(oauth_access_token)
      return graph
    end
  end

  def get_facebook_user
    graph = get_facebook_graph
    return graph.get_object('me') if graph
  end

  def login_from_facebook_session
    graph = get_facebook_graph
    if graph
      begin
        fb_user = graph.get_object('me')
      rescue Exception => e
        logger.warn "login_from_facebook_session failed: " + e.message
        return nil
      end
      oauth_access_token = @facebook_cookies["access_token"]
      user = User.find_by_fb_user_id(fb_user['id'])
      user = User.create_from_fb_connect(fb_user, params[:invitation_token]) if user.nil?
      user.update_attribute(:fb_access_token, oauth_access_token) if user && user.fb_access_token.nil?
      session[:current_user_id] = user.id if user
      return user
    end
  end
  
  # http://stackoverflow.com/questions/5059450/handle-permissions-with-koala-signed-request
  def parse_facebook_signed_request
    if params[:signed_request]
      logger.debug "parse_facebook_signed_request: Signed Request found!"
      @oauth = Koala::Facebook::OAuth.new('callback')  
      @signed_request = @oauth.parse_signed_request(params[:signed_request])  
      if @signed_request["user_id"]  
          @graph = Koala::Facebook::GraphAPI.new(@signed_request["oauth_token"])  
      else  
          redirect_to @oauth.url_for_oauth_code(:permissions => $FACEBOOK_PERMISSIONS);  
      end  
    end
  end
    
  # # Called in ApplicationController: TODO: Remove set_facebook_session_key
  # def set_facebook_session_key
  #   # If logged in, doesn't already have a key, and the new session is infinite/offline
  #   if logged_in? && !current_user.fb_session_key #&& facebook_session.infinite?
  #     current_user.update_attribute(:fb_session_key, facebook_session.session_key)
  #   end
  # end

  def facebook_session_expired
    @current_user = nil
    #clear_fb_cookies!
    #clear_facebook_session_information
    reset_session # remove your cookies!
    flash[:error] = "Your Facebook session has expired."
    redirect_to root_url
  end

  def post_to_wall(fb_user_id, fb_message, fb_image_url, fb_link_name, fb_link_description, fb_link_url)
    # 100001328627765 = Victor, 100002561235684 = Andre, 100000780643287 = Åke B, 635077092 = Tom

    # Offline posting
    # user = User.find_by_name("Victor Oglam")
    # facebook_temp_session = Facebooker::Session.create
    # facebook_temp_session.secure_with!(user.fb_session_key)

    # # Online posting
    # facebook_temp_session = facebook_session
    # 
    # # Create message
    # fb_post_to_user = Facebooker::User.new(fb_user_id) # facebook_temp_session.user
    # post_id = facebook_temp_session.user.publish_to(
    #   fb_post_to_user, 
    #   :message => fb_message,
    #   :attachment => {
    #     :name => fb_link_name,
    #     :description => fb_link_description,
    #     :href => fb_link_url,
    #     :media => [{
    #       :type => "image",
    #       :src => fb_image_url,
    #       :href => fb_link_url }]
    #   }
    # )
    # #flash[:notice] = 'Posted to Facebook: ' + fb_message
      
    begin
      # Graph API: message, picture, link, name, caption, description, source
      logger.debug "post_to_wall: #{fb_user_id}"
      get_facebook_graph.put_connections(fb_user_id, 'feed', { :message => fb_message, :picture => fb_image_url, :link => fb_link_url, :name => fb_link_name, :description => fb_link_description }) # :caption => ?, :source => ?
    rescue
      # Facebook post fail
      #flash[:error] = 'Failed to post to Facebook: ' + post_id.to_s
      logger.warn "Failed to post to Facebook: " + post_id.to_s
    end
    
  end

end