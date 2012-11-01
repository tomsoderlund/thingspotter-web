class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    redirect_to(root_path)
    
    # @users = User.all
    # 
    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.xml  { render :xml => @users }
    # end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    return unless check_if_has_site_access

    @user = User.find(params[:id])

    @view = params[:view]
    @view = 'all' if @view.blank?
    case @view
      when 'wishlist': 
        @spots = @user.wishlist_spots(params[:page])
        set_page_title "#{@user.name}'s Wishlist"
      when 'owned': 
        @spots = @user.owned_spots(params[:page])
        set_page_title "Things that #{@user.name} Owns"
      when 'recommended': 
        @spots = @user.recommended_spots(params[:page])
        set_page_title "#{@user.name}'s Recommended Things"
      else 
        @spots = @user.all_spots(params[:page])
        set_page_title "#{@user.name}'s Things"
    end

    if (current_user && @user == current_user)
      @page_reference = 'mythings'
      @wishlist_url = $SERVER_URL + "/users/" + @user.to_param + "/wishlist"
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    set_page_title 'Sign Up'
    @user = User.new
    #@user = User.new(:invitation_token => params[:invitation_token])
    @invitation_token = params[:invitation_token]
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    return unless check_if_has_site_access

    @user = User.find(params[:id])
    check_if_can_edit_user(@user)
    
    set_page_title 'Settings'
    @page_reference = 'settings'
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    check_if_can_edit_user(@user)

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { 
          if params[:registration]
            redirect_to(intro3_path)
          else
            flash[:notice] = 'Settings were successfully updated.'
            redirect_to(@user)
          end
          
           }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
  
  def link_user_accounts
    
    if facebook_session

      # If is not logged in
      User.create_from_fb_connect(facebook_session.user, params[:invitation_token])
      # if self.current_user.nil?
      #   # Create new User object from Facebook data
      #   User.create_from_fb_connect(facebook_session.user, params[:invitation_token])
      # else
      #   # Connect accounts
      #   self.current_user.link_fb_connect(facebook_session.user.id, params[:invitation_token]) unless (self.current_user.fb_user_id == facebook_session.user.id)
      # end
      if (!self.current_user || !self.current_user.invitation)
        flash[:error] = 'Sorry, but you need an invitation to join Thingspotter right now.'
        redirect_to root_path
      # Decide where to go after login
      elsif (params[:page] == 'intro')
        redirect_to intro2_path
      else
        redirect_to root_path
      end
    else
      # No valid FB session
      flash[:error] = 'Please login to Facebook, then try again.'
      redirect_to intro1_path(:invitation_token => params[:invitation_token])
    end
         
  end

  def import_friends
    @user = User.find(params[:id])
    
    #facebook_user = facebook_session.user #session[:facebook_session].user
    #@friends = facebook_user.friends!(:name, :status).sort_by(&:name) #friends! = force refresh?  , :interests
    @friends = get_facebook_graph.get_connections("me", "friends")
    @import_ok = @user.import_facebook_friends(@friends)
    session["friends_imported"] = @import_ok

    respond_to do |format|
      format.js
      format.xml { render :xml => @user }
    end
  end
      
end