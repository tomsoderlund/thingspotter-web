class Store < ActiveRecord::Base
  
  ### Behavior
  has_many :spots
  
  ### Associations
  ### Validations
  validates_presence_of :name, :url_key
  validates_length_of :name, :within => 2..64
  validates_uniqueness_of :name, :url_key, :case_sensitive => false

  ### Callbacks

  ### Instance Methods

  def to_param
    return "#{id}-#{name.parameterize}"
  end
  
  ### Class Methods

  # Get Store list for dropdowns etc
  def Store.short_list
    return self.find(:all, :order => :name).map do |t| 
      [t.name, t.id] 
    end
  end
  
  def Store.create_from_url(url)
    # TODO: maybe create a find_or_create_from_url instead
    logger.debug "Store.create_from_url: #{url}"
    return nil if url.blank?
    server_name = url.downcase.split('/')[2] # www.amazon.com
    return nil if server_name.blank?
    domain_name_array = server_name.split('.')
    
    if (domain_name_array.length <= 3)
      # e.g. amazon.com
      domain_name = domain_name_array[domain_name_array.length-2] + "." + domain_name_array[domain_name_array.length-1] # amazon.com
      nice_name = domain_name_array[domain_name_array.length-2].capitalize # Amazon
    else
      # e.g. amazon.co.uk
      domain_name = domain_name_array[domain_name_array.length-3] + "." + domain_name_array[domain_name_array.length-2] + "." + domain_name_array[domain_name_array.length-1] # amazon.co.uk
      nice_name = domain_name_array[domain_name_array.length-3].capitalize # Amazon
    end
    
    nice_name = server_name if Store.find_by_name(nice_name)
    url_key = domain_name
    url_key = server_name if Store.find_by_url_key(domain_name)
    return Store.create(:name => nice_name, :url_key => url_key)
  end
      
end