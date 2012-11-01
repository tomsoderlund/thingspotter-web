class HighscoreController < ApplicationController
  
  def things
    
    if params[:view] == 'recent'
      # Show user's Spots
      @spots = Spot.search(nil, "recommended_to_user_id IS NULL", "created_at desc", params[:page])
      @view = 'all_recent'
      set_page_title 'Recent Things'
    elsif params[:view] == 'featured'
      # Show user's Spots
      @spots = Spot.search(nil, ["things.is_featured = ? AND recommended_to_user_id IS NULL", true], "spots.created_at desc", params[:page])
      @view = 'all_featured'
      set_page_title 'Editor\'s Picks'
    else
      @spots = Spot.search(nil, nil, "things.spots_count desc, things.name", params[:page])
      @view = 'all_popular'
      set_page_title 'Popular Things'
    end

    if (@spots.size == 0)
      render :template => 'errors/no_search_results.html.erb'
    else
      respond_to do |format|
        format.html { render :template => 'spots/index.html.erb' }
        format.xml  { render :xml => @spots }
      end
    end
  end

  def users
    @users = User.paginate(:all, :conditions => '(users.fb_session_key IS NOT NULL OR users.fb_access_token IS NOT NULL)', :order => 'users.spots_count desc, users.name', :page => params[:page])
    set_page_title 'Who Spots the Most'
  end

  def brands
    #:conditions => 'brands.things_count > 0', 
    conditions = (params[:name].nil? ? nil : "name like '" + params[:name] + "%'")
    @brands = Brand.paginate(:all, :order => 'brands.things_count desc, brands.name', :conditions => conditions, :page => params[:page])
    set_page_title 'Most Popular Brands'
  end

  def stores
    # :conditions => 'stores.spots_count > 0', 
    conditions = (params[:name].nil? ? nil : "name like '" + params[:name] + "%'")
    @stores = Store.paginate(:all, :order => 'stores.spots_count desc, stores.name', :conditions => conditions, :page => params[:page])
    set_page_title 'Most Popular Stores'
  end
  
  def competition
    dates = date_range
    #logger.debug "Date range: " + dates[:start].strftime("%B %Y") + " -> " + dates[:end].strftime("%B %Y")
    
    @users = User.competition_list(dates[:start], dates[:end])
    @current_month = dates[:start].strftime("%B %Y")
    set_page_title "Current Highscore for #{@current_month}"
  end

end