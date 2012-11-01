class StatisticsController < ApplicationController

  def index
    dates = date_range
    #logger.debug "Date range: " + dates[:start].strftime("%B %Y") + " -> " + dates[:end].strftime("%B %Y")
    @date_range = "#{dates[:start].strftime("%B %e, %Y")} to (not including) #{dates[:end].strftime("%B %e, %Y")}"
    #set_page_title "Current Highscore for #{@current_month}"
    @today = Date.today
    
    # Statistics
    @users_reg = ActiveRecord::Base.connection.select_value("SELECT count(id) AS usercount FROM users WHERE (fb_session_key IS NOT NULL OR fb_access_token IS NOT NULL);").to_i
    @users_reg_range = ActiveRecord::Base.connection.select_value("SELECT count(id) AS usercount FROM users WHERE ((fb_session_key IS NOT NULL OR fb_access_token IS NOT NULL) AND users.created_at > '" + dates[:start].to_s + "' AND users.created_at < '" + dates[:end].to_s + "');").to_i
    @users_no_invite = ActiveRecord::Base.connection.select_value("SELECT count(id) AS usercount FROM users WHERE ((fb_session_key IS NOT NULL OR fb_access_token IS NOT NULL) AND invitation_id IS NULL);").to_i
    @users_active = User.find_by_sql("SELECT user_id AS id FROM spots GROUP BY user_id;").size
    @users_active_range = User.find_by_sql("SELECT user_id AS id FROM spots WHERE (spots.created_at > '" + dates[:start].to_s + "' AND spots.created_at < '" + dates[:end].to_s + "') GROUP BY user_id;").size
    @users_total = ActiveRecord::Base.connection.select_value("SELECT count(id) AS usercount FROM users;").to_i
    @invitations = ActiveRecord::Base.connection.select_value("SELECT count(id) FROM invitations;").to_i
    @invitations_range = ActiveRecord::Base.connection.select_value("SELECT count(id) FROM invitations WHERE (invitations.created_at > '" + dates[:start].to_s + "' AND invitations.created_at < '" + dates[:end].to_s + "');").to_i

    @activity_newspots = ActiveRecord::Base.connection.select_value("SELECT count(id) FROM spots WHERE (spots.created_at > '" + dates[:start].to_s + "' AND spots.created_at < '" + dates[:end].to_s + "' AND spots.original_spot_id IS NULL AND spots.recommended_to_user_id IS NULL);").to_i
    @activity_newspots_users = Spot.find_by_sql("SELECT user_id FROM spots WHERE (spots.created_at > '" + dates[:start].to_s + "' AND spots.created_at < '" + dates[:end].to_s + "' AND spots.original_spot_id IS NULL AND spots.recommended_to_user_id IS NULL) GROUP BY user_id;").size
    @activity_respots = ActiveRecord::Base.connection.select_value("SELECT count(id) FROM spots WHERE (spots.created_at > '" + dates[:start].to_s + "' AND spots.created_at < '" + dates[:end].to_s + "' AND spots.original_spot_id IS NOT NULL);").to_i
    @activity_respots_users = Spot.find_by_sql("SELECT user_id FROM spots WHERE (spots.created_at > '" + dates[:start].to_s + "' AND spots.created_at < '" + dates[:end].to_s + "' AND spots.original_spot_id IS NOT NULL) GROUP BY user_id;").size
    @activity_recommendations = ActiveRecord::Base.connection.select_value("SELECT count(id) FROM spots WHERE (spots.created_at > '" + dates[:start].to_s + "' AND spots.created_at < '" + dates[:end].to_s + "' AND spots.recommended_to_user_id IS NOT NULL);").to_i
    @activity_recommendations_users = Spot.find_by_sql("SELECT user_id FROM spots WHERE (spots.created_at > '" + dates[:start].to_s + "' AND spots.created_at < '" + dates[:end].to_s + "' AND spots.recommended_to_user_id IS NOT NULL) GROUP BY user_id;").size
    @activity_wishlisted = Spot.find(:all, :conditions => ["updated_at > ? AND updated_at < ? AND is_wanted = ?", dates[:start], dates[:end], true]).size
    @activity_wishlisted_users = Spot.find(:all, :conditions => ["updated_at > ? AND updated_at < ? AND is_wanted = ?", dates[:start], dates[:end], true], :group => 'user_id').size
    @activity_owned = Spot.find(:all, :conditions => ["updated_at > ? AND updated_at < ? AND is_owned = ?", dates[:start], dates[:end], true]).size
    @activity_owned_users = Spot.find(:all, :conditions => ["updated_at > ? AND updated_at < ? AND is_owned = ?", dates[:start], dates[:end], true], :group => 'user_id').size
    @activity_comments = ActiveRecord::Base.connection.select_value("SELECT count(id) FROM comments WHERE (created_at > '" + dates[:start].to_s + "' AND created_at < '" + dates[:end].to_s + "');").to_i
    @activity_comments_users = Comment.find(:all, :conditions => ["created_at > ? AND created_at < ?", dates[:start], dates[:end]], :group => 'user_id').size
    @activity_followers = ActiveRecord::Base.connection.select_value("SELECT count(id) FROM followers WHERE (created_at > '" + dates[:start].to_s + "' AND created_at < '" + dates[:end].to_s + "');").to_i
    @activity_followers_users = Follower.find_by_sql("SELECT follower_id FROM followers WHERE (created_at > '" + dates[:start].to_s + "' AND created_at < '" + dates[:end].to_s + "') GROUP BY follower_id;").size
    @users_following = Follower.find_by_sql("SELECT follower_id FROM followers GROUP BY follower_id;").size
    @users_followed = Follower.find_by_sql("SELECT follows_user_id FROM followers GROUP BY follows_user_id;").size
  end

end