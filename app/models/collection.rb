class Collection < ActiveRecord::Base

  ### Behavior
  
  ### Associations
  has_many :collection_things, :dependent => :destroy
  has_many :things, :through => :collection_things
  belongs_to :user

  ### Validations
  validates_presence_of :name, :user
  validates_length_of :name, :within => 2..64

  ### Callbacks
  
  ### Instance Methods
  
  # URL formatting
  def to_param
    return "#{self.id}-#{self.name.gsub(' ', '-').gsub(/[^a-z0-9\-]+/i, '')}".downcase
  end
  
  def add(thing)
    CollectionThing.create(:collection_id => self.id, :thing_id => thing.id)
  end
  
  def spots(user)
    spots = []
    self.things.each do |thing|
      spots << thing.find_spot(user, true)
    end
    return spots
  end
  
  ### Class Methods

  # Class method to get list for dropdowns etc
  def Collection.short_list(user)
    return self.find(:all, :conditions => "user_id = #{user.id}", :order => :name).map do |t| 
      [t.name, t.id] 
    end
  end

end