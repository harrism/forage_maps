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
  
  # Return tuckers from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  
  private
  
    # Return an SQL condition for users followed by the given user.
    # We include the user's own id as well.
  
    def self.followed_by(user)
      following_ids = %(SELECT followed_id FROM relationships
                        WHERE follower_id = :user_id)
      where("user_id IN (#{following_ids}) OR user_id = :user_id", 
            { :user_id => user })  
    end
end
