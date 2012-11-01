class CollectionsController < ApplicationController

  #before_filter :check_if_has_site_access
  
  # GET /collections
  # GET /collections.xml
  def index
    load_welcome_new_user_info

    if params[:user_id]
      # Show user's Collections
      @collections = Collection.paginate(:all, :conditions => "user_id = #{current_user.id}", :order => 'updated_at desc, name', :page => params[:page])
      @view = 'my_collections'
    else
      # All Collections
      @collections = Collection.paginate(:all, :order => 'updated_at desc, name', :page => params[:page])
      @view = 'all_collections'
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @collections }
    end
  end

  # GET /collections/1
  # GET /collections/1.xml
  def show
    load_welcome_new_user_info

    @collection = Collection.find(params[:id])
    set_page_title @collection.name
    @page_description = @collection.description

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collection }
    end
  end

  # GET /collections/new
  # GET /collections/new.xml
  def new
    return nil unless check_if_has_site_access
    
    @collection = Collection.new
    set_page_title 'New Collection'

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collection }
    end
  end

  # GET /collections/1/edit
  def edit
    @collection = Collection.find(params[:id])
    set_page_title "Edit Collection"
  end

  # POST /collections
  # POST /collections.xml
  def create
    @collection = Collection.new(params[:collection])
    @collection.user = current_user

    respond_to do |format|
      if @collection.save
        flash[:notice] = 'Collection was successfully created.'
        format.html { redirect_to(@collection) }
        format.xml  { render :xml => @collection, :status => :created, :location => @collection }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collection.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /collections/1
  # PUT /collections/1.xml
  def update
    @collection = Collection.find(params[:id])

    respond_to do |format|
      if @collection.update_attributes(params[:collection])
        flash[:notice] = 'Collection was successfully updated.'
        format.html { redirect_to(@collection) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collection.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.xml
  def destroy
    @collection = Collection.find(params[:id])
    @collection.destroy

    respond_to do |format|
      format.html { redirect_to(collections_url) }
      format.xml  { head :ok }
    end
  end
end
