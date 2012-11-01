class PagesController < ApplicationController
  
  # GET /pages
  # GET /pages.xml
  def index
    return unless check_if_admin_access
    
    @pages = Page.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    return unless (params[:id] == 'about' || check_if_has_site_access)

    @page = Page.find_by_permalink(params[:id])
    
    if @page
      set_page_title @page.title

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @page }
      end
    else
      # No page found
      redirect_to root_path
    end
    
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    return if !check_if_admin_access
    
    @page = Page.new
    @page.user = current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    return if !check_if_admin_access
    @page = Page.find_by_permalink(params[:id])
  end

  # POST /pages
  # POST /pages.xml
  def create
    return if !check_if_admin_access
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to(@page) }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    return if !check_if_admin_access
    @page = Page.find_by_permalink(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to(@page) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    return if !check_if_admin_access
    @page = Page.find_by_permalink(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end
  
end