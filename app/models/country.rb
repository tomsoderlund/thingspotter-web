class Country < ActiveRecord::Base


  # Class method to get list for dropdowns etc
  def Country.short_list
    return self.find(:all, :order => :name).map do |t| 
      [t.name, t.id] 
    end
  end

end
