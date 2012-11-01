class RecommendationsController < ApplicationController

  def new
    set_page_title 'New Recommendation'
    @spot = Spot.new
    @spot.thing = Thing.find(params[:thing])
    @spot.comment = Comment.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @spot }
    end
  end

  def create
    @spot = Spot.new(params[:spot])
    @spot.user = current_user
    
    # Nullify - TODO: refactor this
    if @spot.comment.comment.blank?
      @spot.comment = nil
    else
      @spot.comment.thing = @spot.thing
      @spot.comment.user = @spot.user
    end

    respond_to do |format|
      if @spot.save

        # Post to their Facebook
        if params[:post_to_their_facebook] == 'true'
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
        end

        flash[:notice] = "Recommendation sent to #{@spot.recommended_to_user.name}!"
        #format.html { redirect_to(@spot) }
        format.html { redirect_to(spots_path) }
        format.xml  { render :xml => @spot, :status => :created, :location => @spot }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @spot.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
  end

end