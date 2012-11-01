class FollowingsController < ApplicationController

  before_filter :check_if_has_site_access

  def index
    @title = 'You Are Following'
    set_page_title 'Who You Are Following'
    
    if current_user
      @followers = current_user.following_users
    else
      @followers = []
    end

    respond_to do |format|
      format.html { render :template => 'followers/index.html.erb' }
      format.xml  { render :xml => @followers }
    end
  end


end
