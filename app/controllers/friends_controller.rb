class FriendsController < ApplicationController

  before_filter :check_if_has_site_access
  
  # GET /friends
  # GET /friends.xml
  def index
    
    if current_user
      if params[:name]
        @friend_users = current_user.find_friend_users(params[:name], true).paginate(:page => params[:page])
      else
        @friend_users = current_user.find_friend_users(nil, true).paginate(:page => params[:page])
      end
    else
      # Null result
      @friend_users = [].paginate(:page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.js { @friend_users = current_user.find_following_users(params[:name]) + @friend_users }
      format.xml  { render :xml => @friend_users }
    end
  end

end