class IntroController < ApplicationController

  layout 'limited' #:select_layout
  #before_filter :check_if_has_site_access
  #skip_before_filter :verify_authenticity_token
  before_filter :get_view_name
  
  def get_view_name
    @view = params[:action]
  end
  
  def step1
    # If used FB Login button and is old user (> 5 minutes), skip intro
    redirect_to root_path if params[:just_logged_in] && current_user && (Time.zone.now - current_user.created_at) > (60 * 5)

    @invitation_token = params[:invitation_token]
    set_page_title 'Thingspotter: Welcome!', false

    # INVITE BEHAVIOR: change here
    #@have_access = (@invitation_token || current_user)
    @have_access = true

    if !@have_access
      flash[:error] = 'Warning: you don\'t have a beta invite (<a href="/">more info</a>).'
    end
  end

  def step2
    @invitation_token = params[:invitation_token]
    return if !(@invitation_token || check_if_has_site_access)
    set_page_title 'Thingspotter: Sign Up', false
    
    @user = current_user || User.new
  end

  def step3
    return if !check_if_has_site_access
    
    set_page_title 'Thingspotter: Install Bookmarklet', false

    # spots_selection = Spot.find(:all, :include => [:thing], :select => "thing_id, count(spots.id) as spot_count, max(spots.id) as id", :group => "thing_id", :order => "spot_count desc", :limit => 4)
    # thing_ids = ""
    # spots_selection.each do |spot|
    #   thing_ids += spot.thing_id.to_s + ', '
    # end
    # thing_ids = thing_ids[0, thing_ids.length-2]
    # @spots = Spot.search(nil, "thing_id in (" + thing_ids + ")", nil, nil, 4)

    #@spots = Spot.search(nil, "recommended_to_user_id IS NULL", "created_at desc", params[:page], 4)
  end

  def step4
    return if !check_if_has_site_access
    
    set_page_title 'Thingspotter: Find Friends', false
    
    current_user.set_user_followings

    @friends = current_user.find_friend_users(nil, false).sort_by(&:spots_count).reverse[0..4]
    # Clean non-users
    # @friends.each do |user|
    #   result_list.delete(user) if user.id.nil?
    # end

    #@good_thingspotters = User.find(:all, :order => "spots_count desc", :limit => 5)
    @good_thingspotters = current_user.related_users[0..4]

  end

  # def step4
  #   return if !check_if_has_site_access
  #   
  #   set_page_title 'Thingspotter: Get Going!', false
  # end

end