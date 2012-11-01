# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def simple_button_to(text, url, css_class)
    link_to(text, url, :class => "menu")
  end
  
  def image_toggler_tag(field_id, default_value = true, label = '', create_field_tag = true)
    element_id = 'imagetoggler_' + field_id
    default_class = (default_value ? element_id + '_on' : element_id + '_off')
    return_str = link_to_function(label.to_s, 'imageToggle(this.id, "' + field_id + '");', :id => element_id, :class => default_class)
    return_str += hidden_field_tag(field_id, default_value.to_s) if create_field_tag
    return return_str
  end

  # Format date in a relative manner, e.g. "Yesterday"
  def relative_date(dateobj)
    days = ((Time.zone.parse(dateobj.to_s) - Time.zone.now) / (24*60*60)).to_i
    return 'tomorrow ' + dateobj.strftime('%H:%M') if (dateobj - 1.day).today?
    return 'today ' + dateobj.strftime('%H:%M') if dateobj.today?
    return 'yesterday ' + dateobj.strftime('%H:%M') if (dateobj + 1.day).today?
    return dateobj.strftime('%b %e') if days.abs < 182
    return dateobj.strftime('%b %e, %Y')
  end
  
  def user_or_you(user)
    return '' if user.nil?
    if current_user && user == current_user
      #return 'You'
      return link_to('You', user)
    else
      return link_to(h(user.name), user)
    end
  end
  
  def website_from_url(url)
    return '' if url.nil?
    website = url.split('/')[2]
    website = website.to_s.gsub('www.', '').capitalize
    return website
  end

  include ActionView::Helpers::NumberHelper
  
  def format_price(value, currency_symbol)
    precision = 0
    precision = 2 if value < 10.0
    return number_with_precision(value, { :precision => precision, :delimiter => "'" }) + ' ' + currency_symbol
  end
  
  def price_formatted(spot)
    return format_price(spot.price, reverse_lookup_in_array(spot.currency_id, User.currency_list))
  end

  def price_formatted_in_users_currency(spot, user)
    user.currency_id = 0 if user.currency_id.nil?
    return format_price((spot.price * $CURRENCY_EXCHANGE_RATES[spot.currency_id] / $CURRENCY_EXCHANGE_RATES[user.currency_id]), reverse_lookup_in_array(user.currency_id, User.currency_list))
  end
  
  # Link that posts to Facebook
  def facebook_share_link(url, title)
    facebook_url = "https://www.facebook.com/sharer.php?u=#{CGI::escape(url)}&t=#{CGI::escape(title)}"
    return link_to('', facebook_url, :target => 'blank', :class => 'ts_icon_social ts_facebook')
  end
  
  # Link that posts to Twitter
  def twitter_share_link(url, title)
    #return '<a href="http://twitter.com/share" class="twitter-share-button" data-url="' + url + '" data-text="' + title + '" data-count="none" data-via="tomsoderlund">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>'
    #https://twitter.com/share?original_referer=http%3A%2F%2Flocalhost%3A3000%2Fthings%2F21-ferrari-california&source=tweetbutton&text=Ferrari%20California%20on%20Thingspotter&url=http%3A%2F%2Flocalhost%3A3000%2Fthings%2F21-ferrari-california&via=tomsoderlund
    title = title.sub("Thingspotter", "#Thingspotter")
    twitter_url = "https://twitter.com/share?source=tweetbutton&text=#{CGI::escape(title)}&url=#{CGI::escape(url)}&original_referer=#{CGI::escape(title)}"
    return link_to('', twitter_url, :target => 'blank', :class => 'ts_icon_social ts_twitter')
  end
    
end