class Tucker < ActiveRecord::Base
  attr_accessible :title, :description, :lat, :lng
  
  belongs_to :user
  
  validates :title, :presence => true, :length => { :maximum => 50 }
  validates :description, :length => { :maximum => 500 }
  validates :user_id, :presence => true
  validates :lat, :lng, :presence => true
  validates :lat, :numericality => {
    :greater_than_or_equal_to => -90.0,
    :less_than_or_equal_to => 90.0
  }
  validates :lng, :numericality => {
    :greater_than_or_equal_to => -180.0,
    :less_than_or_equal_to => 180.0
  }
  
  default_scope :order => 'tuckers.created_at DESC'
end
