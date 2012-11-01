class SpotsController < ApplicationController

  before_filter :check_if_has_site_access

  # GET /spots
  # GET /spots.xml
  def index
    load_welcome_new_user_info
    
    @page = (params[:page] || 1)
    
    if params[:search]
      # Search for Things
      @spots = Spot.search(params[:search], nil, nil, params[:page])
      set_page_title params[:search].titleize
    elsif params[:user_id]
      # Show user's Spots
      @spots = Spot.search(nil, ("user_id = " + (params[:user_id]).to_i), nil, params[:page])
      set_page_title 'Thingspotter', false
    elsif current_user
      # Show subscribed
      if params[:view] == 'popular'
        @view = 'friends_popular'
        @spots = current_user.subscribed_spots(params[:page], "things.spots_count desc, things.name")
      else
        @view = 'friends_recent'
        @spots = current_user.subscribed_spots(params[:page])
      end
      set_page_title 'Thingspotter', false
    else
      # Show all
      @spots = Spot.search(nil, "recommended_to_user_id IS NULL", nil, params[:page])
      set_page_title 'Thingspotter', false
    end
    
    if (@spots.size == 0)
      render :template => 'errors/no_search_results.html.erb'
    else
      respond_to do |format|
        format.html # index.html.erb
        format.js # index.js
        format.xml  { render :xml => @spots }
      end
    end

  end

  # GET /spots/1
  # GET /spots/1.xml
  def show
    @spot = Spot.find(params[:id])

    set_page_title @spot.thing.name_with_brand

    respond_to do |format|
      format.html {
        if params[:imagespotter]
          render :action => 'show_imagespotter', :layout => 'imagespotter'
        else
          render :action => 'show'
        end
      }
      format.xml  { render :xml => @spot }
    end
  end

  # GET /spots/new
  # GET /spots/new.xml
  def new
    if current_user
      @mode = params[:mode]
      @mode = 'add' if @mode.blank?

      set_page_title @mode.capitalize + ' New Thing'
      @page_reference == 'addthing'

      @spot = Spot.new

      @spot.is_wanted = true if @mode == 'want'
      @spot.is_owned = true if @mode == 'own'

      @spot.currency_id = current_user.currency_id
      @spot.website_url = params[:url] unless params[:url].blank?

      if params[:thing]
        #logger.debug 'EXISTING THING'
        @spot.thing = Thing.find(params[:thing])
        @edit_thing = false
      else
        #logger.debug 'NEW THING'
        @spot.thing = Thing.new
        @edit_thing = true
        #@spot.thing.name = 'New Thing'
        begin
          @spot.fetch_data_from_url(params[:url]) unless params[:url].blank?
        rescue
          flash[:error] = 'Could not retrieve information from that website.'
        end
        @spot.thing.photo_url = params[:image] unless params[:image].blank?
        @spot.thing.guess_brand
      end

      @spot.comment = Comment.new

      respond_to do |format|
        format.html {# index.html.erb
          if params[:imagespotter]
            render :action => 'new_imagespotter', :layout => 'imagespotter'
          else
            render :action => 'new'
          end
        }
        format.xml  { render :xml => @spot }
      end
    else
      # No current_user
      redirect_to intro1_path
    end
  end

  # GET /spots/1/edit
  def edit
    @spot = Spot.find(params[:id])
    set_page_title "Edit #{@spot.thing.name_with_brand}"
    
    @edit_thing = can_edit_thing?(@spot.thing)
  end

  # POST /spots
  # POST /spots.xml
  def create
    @spot = Spot.new(params[:spot])
    @spot.user = current_user
    # Existing thing?
    if params[:spot][:thing_attributes][:id]
      @spot.thing = Thing.find(params[:spot][:thing_attributes][:id])
    else
      @spot.thing.user = current_user
    end
    
    respond_to do |format|
      if @spot.save
        
        # Collection: add Thing?
        if (params[:collection_thing] && !params[:collection_thing][:collection_id].blank?)
          @collection_thing = CollectionThing.new(params[:collection_thing])
          @collection_thing.thing = @spot.thing
          @collection_thing.save
        end
        
        # Post to Facebook
        if params[:post_to_your_facebook] == 'true'
          fb_user_id = @spot.user.fb_user_id
          fb_message = "Just #{@spot.action_verb.downcase} #{@spot.thing.name_with_brand} on Thingspotter!"
          fb_image_url = root_url.slice(0, root_url.length-1) + @spot.thing.photo_path(:web_thumb)
          fb_link_name = "#{@spot.thing.name_with_brand}"
          fb_link_description = "#{@spot.thing.description}"
          fb_link_url = thing_url(@spot.thing)
          post_to_wall(fb_user_id, fb_message, fb_image_url, fb_link_name, fb_link_description, fb_link_url)
        end
        flash[:notice] = 'Thing was successfully spotted!'

        # Post to their Facebook
        if params[:post_to_their_facebook] == 'true' && @spot.recommended_to_user
          fb_user_id = @spot.recommended_to_user.fb_user_id
          if @spot.comment
            fb_message = @spot.comment.comment
          else
            fb_message = "Check out #{@spot.thing.name_with_brand} on Thingspotter!"
          end
          fb_image_url = root_url.slice(0, root_url.length-1) + @spot.thing.photo_path(:web_thumb)
          fb_link_name = "#{@spot.thing.name_with_brand}"
          fb_link_description = "#{@spot.thing.description}"
          fb_link_url = thing_url(@spot.thing)
          post_to_wall(fb_user_id, fb_message, fb_image_url, fb_link_name, fb_link_description, fb_link_url)
          
          flash[:notice] = "Recommendation sent to #{@spot.recommended_to_user.name}!"
        end
        
        #format.html { redirect_to(@spot) }
        format.html { 
          if params[:imagespotter]
            #render :action => 'show_imagespotter', :layout => 'imagespotter'
            flash[:notice] = nil
            redirect_to(spot_path(@spot, {:imagespotter => true}))
          else
            redirect_to(spots_path) 
          end
        }
        format.xml  { render :xml => @spot, :status => :created, :location => @spot }
      else
        # Error
        @mode = 'add'
        format.html { 
          @spot.comment = Comment.new if @spot.comment.nil?
          if params[:imagespotter]
            render :action => 'new_imagespotter', :layout => 'imagespotter' 
          else
            render :action => 'new' 
          end
          }
        format.xml  { render :xml => @spot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /spots/1
  # PUT /spots/1.xml
  def update
    @spot = Spot.find(params[:id])

    respond_to do |format|
      if @spot.update_attributes(params[:spot])
        flash[:notice] = 'Spot was successfully updated.'
        format.html { redirect_to(@spot.thing) }
        #format.html { redirect_to(spots_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @spot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /spots/1
  # DELETE /spots/1.xml
  def destroy
    @spot = Spot.find(params[:id])
    @spot.destroy

    respond_to do |format|
      format.html { redirect_to(spots_path) }
      format.xml  { head :ok }
    end
  end

  # Add (+) button
  def toggle_share
    @spot = Spot.find(params[:id])
    @is_shared = @spot.thing.toggle_shared(current_user, @spot.id)
    flash[:notice] = "#{@spot.thing.name_with_brand} is " + (@is_shared ? 'now' : 'no longer')+ " added to your feed."

    respond_to do |format|
      format.html { redirect_to(@spot) }
      format.js
      format.xml  { head :ok }
    end
  end

  # Wishlist (♥) button
  def toggle_want
    @spot = Spot.find(params[:id])
    @is_wanted = @spot.thing.toggle_wanted(current_user)
    flash[:notice] = "#{@spot.thing.name_with_brand} is " + (@is_wanted ? 'now' : 'no longer')+ " added to your wishlist."

    respond_to do |format|
      format.html { redirect_to(@spot) }
      format.js
      format.xml  { head :ok }
    end
  end

  # Own This (✓) button
  def toggle_own
    @spot = Spot.find(params[:id])
    @is_owned = @spot.thing.toggle_owned(current_user)
    flash[:notice] = "#{@spot.thing.name_with_brand} is " + (@is_owned ? 'now' : 'no longer')+ " marked as owned."

    respond_to do |format|
      format.html { redirect_to(@spot) }
      format.js
      format.xml  { head :ok }
    end
  end
  
end