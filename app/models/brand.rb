class Brand < ActiveRecord::Base
  
  ### Behavior
  has_many :things
  
  ### Associations
  ### Validations
  validates_presence_of :name
  validates_length_of :name, :within => 2..64
  validates_uniqueness_of :name, :case_sensitive => false

  ### Callbacks

  ### Instance Methods
  
  def to_param
    return "#{id}-#{name.parameterize}"
  end
  
  ### Class Methods

  # Get Brand list for dropdowns etc
  def Brand.short_list
    return self.find(:all, :order => :name).map do |t| 
      [t.name, t.id] 
    end
  end
      
end