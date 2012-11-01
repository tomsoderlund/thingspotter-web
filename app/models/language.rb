class Language < ActiveRecord::Base
  
  
  
  # Class method to get list for dropdowns etc
  def Language.short_list
    return self.find(:all, :order => :name).map do |t| 
      [t.name, t.id] 
    end
  end

end
