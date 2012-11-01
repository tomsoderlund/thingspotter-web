# NOTE: Methods for Controllers and Models, not only Views
# Include with:
# require 'lib/thingspotter_lib'; include ThingspotterLib

module ThingspotterLib

  # e.g. lookup_in_array('GBP', User.currency_list)
  def lookup_in_array(value, array)
    for i in 0..(array.size - 1)
      return array[i][1] if array[i][0] == value
    end
    return nil
  end

  # e.g. reverse_lookup_in_array(2, User.currency_list)
  def reverse_lookup_in_array(value, array)
    for i in 0..(array.size - 1)
      return array[i][0] if array[i][1] == value
    end
    return nil
  end
    
  # def root_url_without_slash
  #   return root_url.slice(0, root_url.length-1)
  # end
  
end