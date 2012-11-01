class FollowersController < ApplicationController

  before_filter :check_if_has_site_access
  
  # GET /followers
  # GET /followers.xml
  def index
    @title = 'Who Are Following You'
    set_page_title 'Who Are Following You'

    if current_user
      @followers = current_user.follower_users
    else
      @followers = []
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @followers }
    end
  end
  
  # GET /followers/1
  # GET /followers/1.xml
  def show
    @follower = Follower.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @follower }
    end
  end

  # GET /followers/new
  # GET /followers/new.xml
  def new
    @follower = Follower.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @follower }
    end
  end

  # POST /followers
  # POST /followers.xml
  def create
    @follower = Follower.new(params[:follower])
    flash[:user_id] = @follower.follows_user_id

    respond_to do |format|
      if @follower.save
        flash[:notice] = "You are now following #{@follower.follows_user.name}"
        format.html { redirect_to(@follower) }
        format.js
        format.xml  { render :xml => @follower, :status => :created, :location => @follower }
      else
        format.html { render :action => "new" }
        format.js
        format.xml  { render :xml => @follower.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /followers/1
  # DELETE /followers/1.xml
  def destroy
    @follower = Follower.find(params[:id])
    flash[:user_id] = @follower.follows_user_id
    flash[:notice] = "You are no longer following #{@follower.follows_user.name}"
    @follower.destroy

    respond_to do |format|
      format.html { redirect_to(followers_url) }
      format.js
      format.xml  { head :ok }
    end
  end

end