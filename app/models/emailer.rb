class Emailer < ActionMailer::Base
  
  #default :from => "from@example.com"

  # Email: <Thingspotter> "You are invited!"
  def invitation(invitation, full_name, signup_url, invitation_type = '1')
    setup_standard_email
    full_name = Emailer.name_from_email(invitation.recipient_email) if full_name.blank?
    @recipients = "#{full_name} <#{invitation.recipient_email}>"
    @body[:invitation] = invitation
    @body[:signup_url] = signup_url
    @body[:recipient_email] = invitation.recipient_email
    @body[:user_count] = User.find(:all, :conditions => "(fb_session_key IS NOT NULL OR fb_access_token IS NOT NULL)").size
    @body[:from_user_name] = (invitation.sender.nil? ? "" : invitation.sender.name)
    invitation.update_attribute(:sent_at, Time.now)
    if (invitation_type == '2')
      @subject = "Välkommen till Thingspotter Beta!" # "You are invited!"
      template 'invitation_sv'
    else
      @subject = "Welcome to Thingspotter Beta!" # "You are invited!"
      template 'invitation_en'
    end
  end

  # Email: <Thingspotter> "Victor Oglam just started following you!"
  def follows_user_notification(user, follower)
    setup_email_for_user(user)
    @subject = "#{follower.name} just started following you!"
    @body[:follower] = follower
    @body[:follower_url] = $SERVER_URL + "/users/" + follower.to_param + "?" + @body[:google_url_tags]
  end

  # Email: <Thingspotter> "Victor Oglam recommended Bravo Bokstavskex to you"
  def recommendation_notification(user, spot)
    setup_email_for_user(user)
    @subject = "#{spot.user.name} recommended #{spot.thing.name_with_brand} to you"
    @body[:spot] = spot
    @body[:user_url] = $SERVER_URL + "/users/" + spot.user.to_param + "?" + @body[:google_url_tags]
    @body[:thing_url] = $SERVER_URL + "/things/" + spot.thing.to_param + "?" + @body[:google_url_tags]
    @body[:thing_photo_url] = $SERVER_URL + spot.thing.photo_path(:web_thumb)
  end

  # Email: <Thingspotter> "Victor Oglam just wishlisted your spot Bravo Bokstavskex"
  def new_spot_notification(user, spot)
    setup_email_for_user(user)
    @subject = "#{spot.user.name} just #{spot.action_verb.downcase} your spot #{spot.thing.name_with_brand}"
    @body[:spot] = spot
    @body[:user_url] = $SERVER_URL + "/users/" + spot.user.to_param + "?" + @body[:google_url_tags]
    @body[:thing_url] = $SERVER_URL + "/things/" + spot.thing.to_param + "?" + @body[:google_url_tags]
    @body[:thing_photo_url] = $SERVER_URL + spot.thing.photo_path(:web_thumb)
  end

  # Email: <Thingspotter> "Victor Oglam just wishlisted your spot Bravo Bokstavskex"
  def featured_notification(user, thing)
    setup_email_for_user(user)
    @subject = "Your spot #{thing.name_with_brand} is now an Editor\'s Pick"
    @body[:thing] = thing
    @body[:featured_url] = $SERVER_URL + "/highscore/things?view=featured&" + @body[:google_url_tags]
    @body[:thing_url] = $SERVER_URL + "/things/" + thing.to_param + "?" + @body[:google_url_tags]
    @body[:thing_photo_url] = $SERVER_URL + thing.photo_path(:web_thumb)
  end

  # Email: <Thingspotter> "Victor Oglam commented on Bravo Bokstavskex"
  def comment_notification(user, comment)
    setup_email_for_user(user)
    @subject = "#{comment.user.name} commented on #{comment.thing.name_with_brand}"
    @body[:comment] = comment
    @body[:user_url] = $SERVER_URL + "/users/" + comment.user.to_param + "?" + @body[:google_url_tags]
    @body[:thing_url] = $SERVER_URL + "/things/" + comment.thing.to_param + "?" + @body[:google_url_tags]
    @body[:thing_photo_url] = $SERVER_URL + comment.thing.photo_path(:web_thumb)
  end

  # Email: <Thingspotter> "Victor Oglam added Bravo Bokstavskex to their collection"
  def collection_added_notification(user, collection, thing)
    setup_email_for_user(user)
    @subject = "#{collection.user.name} added #{thing.name_with_brand} to their collection"
    @body[:collection] = collection
    @body[:thing] = thing
    @body[:user_url] = $SERVER_URL + "/users/" + collection.user.to_param + "?" + @body[:google_url_tags]
    @body[:thing_url] = $SERVER_URL + "/things/" + thing.to_param + "?" + @body[:google_url_tags]
    @body[:collection_url] = $SERVER_URL + "/collections/" + collection.to_param + "?" + @body[:google_url_tags]
    @body[:thing_photo_url] = $SERVER_URL + thing.photo_path(:web_thumb)
  end

  def Emailer.name_from_email(email)
    address_array = email.split('@')
    return address_array[0].gsub('.', ' ').titleize
  end

  protected

    def setup_email_for_user(user)
      setup_standard_email
      @recipients = "#{user.name} <#{user.email}>"
      @body[:user] = user
      @body[:recipient_email] = user.email
    end

    def setup_standard_email
      content_type "text/html"
      #@from = $EMAIL_SENDER_ADDRESS
      @from = "#{$EMAIL_SENDER_NAME} <#{$EMAIL_SENDER_ADDRESS}>"
      #headers  "return-path" => $EMAIL_SENDER_ADDRESS
      @sent_on = Time.now
      @body[:url] = $SERVER_URL
      @body[:google_url_tags] = "utm_source=emailnotification&utm_medium=email&utm_campaign=emailnotification"
    end
    
end