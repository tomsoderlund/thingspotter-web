class Page < ActiveRecord::Base

  # Relations
  belongs_to :user

  # Validations
  validates_presence_of   :permalink, :title, :body

  
  # URL find parameter
  def to_param
    return permalink
  end
  
end