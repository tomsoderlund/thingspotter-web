class CollectionThingsController < ApplicationController
  # GET /collection_things
  # GET /collection_things.xml
  def index
    @collection_things = CollectionThing.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @collection_things }
    end
  end

  # GET /collection_things/1
  # GET /collection_things/1.xml
  def show
    @collection_thing = CollectionThing.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collection_thing }
    end
  end

  # GET /collection_things/new
  # GET /collection_things/new.xml
  def new
    @collection_thing = CollectionThing.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collection_thing }
    end
  end

  # GET /collection_things/1/edit
  def edit
    @collection_thing = CollectionThing.find(params[:id])
  end

  # POST /collection_things
  # POST /collection_things.xml
  def create
    @collection_thing = CollectionThing.new(params[:collection_thing])

    respond_to do |format|
      if @collection_thing.save
        flash[:notice] = 'Thing was successfully added to collection.'
        format.html { redirect_to(@collection_thing.thing) }
        format.js {}
        format.xml  { render :xml => @collection_thing, :status => :created, :location => @collection_thing }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collection_thing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /collection_things/1
  # PUT /collection_things/1.xml
  def update
    @collection_thing = CollectionThing.find(params[:id])

    respond_to do |format|
      if @collection_thing.update_attributes(params[:collection_thing])
        flash[:notice] = 'CollectionThing was successfully updated.'
        format.html { redirect_to(@collection_thing) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collection_thing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_things/1
  # DELETE /collection_things/1.xml
  def destroy
    @collection_thing = CollectionThing.find(params[:id])
    @collection = @collection_thing.collection
    @collection_thing.destroy

    respond_to do |format|
      format.html { redirect_to(@collection) }
      format.xml  { head :ok }
    end
  end
end
