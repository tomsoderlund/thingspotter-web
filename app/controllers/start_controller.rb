class StartController < ApplicationController

  require 'open-uri'
  require 'rubygems'
  #require 'hpricot'

  def image_spotter
    if current_user
      set_page_title nil
      @user = facebook_session.user #session[:facebook_session].user
      #@friends = @user.friends!(:name, :status).sort_by(&:name) #friends! = force refresh?  , :interests
    end
  end

  def test_post
    flash[:notice] = 'Testing completed.'
    redirect_to root_path
  end

  def test_web
    test_url = 'http://www.paradoxplaza.com'
    html = Nokogiri::HTML(open(test_url).read)
    # This would search for any images inside a paragraph (XPath)
    logger.debug html.xpath('/html/body//p//img')
    # This would search for any images with the class "test" (CSS selector)
    logger.debug html.css('img') #img.test 

    flash[:notice] = 'Nokogiri testing completed.'
    redirect_to root_path
  end

end