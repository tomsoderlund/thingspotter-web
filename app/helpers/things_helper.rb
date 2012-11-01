module ThingsHelper
  
  def productphoto_placeholder_photo_url(size)
    if (size == 'web_thumb')
      return 'productphoto_placeholder_small.png'
    else
      return 'productphoto_placeholder.png'
    end
  end
  
end
