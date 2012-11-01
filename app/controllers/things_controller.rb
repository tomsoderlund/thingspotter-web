class ThingsController < ApplicationController
  # GET /things
  # GET /things.xml
  def index
    if (is_admin?)
      @things = Thing.all

      respond_to do |format|
        format.html # index.html.erb
        format.xml { render :xml => @things }
      end
    else
      redirect_to root_path 
    end
  end

  # GET /things/1
  # GET /things/1.xml
  def show
    load_welcome_new_user_info

    @thing = Thing.find(params[:id])
    set_page_title @thing.name_with_brand
    @page_description = @thing.description
    @page_keywords += ",#{@thing.brand_name},#{@thing.name}" if @thing.brand
    
    @comment = Comment.new
    @comment.thing = @thing
    
    check_if_has_site_access(false)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @thing }
    end
  end

  # GET /things/new
  # GET /things/new.xml
  def new
    @thing = Thing.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @thing }
    end
  end

  # GET /things/1/edit
  def edit
    @thing = Thing.find(params[:id])
  end

  # POST /things
  # POST /things.xml
  def create
    @thing = Thing.new(params[:thing])

    respond_to do |format|
      if @thing.save
        flash[:notice] = 'Thing was successfully created.'
        format.html { redirect_to(@thing) }
        format.xml  { render :xml => @thing, :status => :created, :location => @thing }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @thing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /things/1
  # PUT /things/1.xml
  def update
    @thing = Thing.find(params[:id])

    respond_to do |format|
      if @thing.update_attributes(params[:thing])
        flash[:notice] = 'Thing was successfully updated.'
        format.html { redirect_to(@thing) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @thing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /things/1
  # DELETE /things/1.xml
  def destroy
    @thing = Thing.find(params[:id])
    @thing.destroy

    respond_to do |format|
      format.html { redirect_to(highscore_brands_url) }
      format.xml  { head :ok }
    end
  end
  
  def merge
    @thing_from = Thing.find(params[:id])
    thing_to_url_array = params[:thing_to_url].split('/')
    @thing_to = Thing.find(thing_to_url_array[thing_to_url_array.size-1])
    #logger.debug "MERGE #{@thing_from.name} -> #{@thing_to.name}"
    Thing.merge(@thing_from, @thing_to)

    respond_to do |format|
      format.html { redirect_to(@thing_to) }
      format.xml  { head :ok }
    end
  end

  # Toggle featured
  def toggle_featured
    @thing = Thing.find(params[:id])
    @thing.is_featured = !@thing.is_featured

    respond_to do |format|
      if @thing.save
        # Email notification
        if @thing.is_featured
          Emailer.deliver_featured_notification(@thing.user, @thing)
        end
        
        flash[:notice] = "#{@thing.name_with_brand} is now" + (@thing.is_featured == false ? ' not' : '') + " featured!"
        format.html { redirect_to(@thing) }
        format.js
        format.xml  { render :xml => @thing, :status => :updated, :location => @thing }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @thing.errors, :status => :unprocessable_entity }
      end
    end

  end
  
  def search_autosuggest
    @search_options = Thing.get_default_tags
    respond_to do |format|
      format.js
    end
  end
  
end