require 'spec_helper'

describe Tucker do
  
  before(:each) do
    @user = Factory(:user)
    @attr = {
      :title => "A Food",
      :description => "Growing somewhere.",
      :address => "Central Park, New York, NY"
    }
  end
  
  it "should create a new instance given valid attributes" do
    @user.tuckers.create!(@attr)
  end
  
  describe "user associations" do
    
    before(:each) do
      @tucker = @user.tuckers.create(@attr)
    end
    
    it "should have a user attribute" do
      @tucker.should respond_to(:user)
    end
    
    it "should have the right associated user" do
      @tucker.user_id.should == @user.id
      @tucker.user.should == @user
    end
  end
  
  describe "validations" do
    
    it "should require a user_id" do
      Tucker.new(@attr).should_not be_valid
    end
    
    it "should require nonblank title" do
      @user.tuckers.build(:title => "    ").should_not be_valid
    end
    
    it "should require nonblank address" do
      @user.tuckers.build(:address => "    ").should_not be_valid
    end
        
    it "should reject long titles" do
      @user.tuckers.build(:title => "a" * 51).should_not be_valid
    end
    
    it "should reject long descriptions" do
      @user.tuckers.build(:description => "a" * 501).should_not be_valid
    end
    
    it "should reject long addresses" do
      @user.tuckers.build(:address => "a" * 501).should_not be_valid
    end
    
    it "should have lat and lng of 0.0 by default" do
      t = @user.tuckers.build(:title => "Foo")
      t.latitude.should == 0.0
      t.longitude.should == 0.0
    end
    
    it "should reject latitudes outside [-90, 90]" do
      @user.tuckers.build(:title => "Foo", :latitude => -100.0).should_not be_valid
      @user.tuckers.build(:title => "Foo", :latitude =>  150.0).should_not be_valid
      @user.tuckers.build(:title => "Foo", :latitude =>  -90.0).should be_valid
      @user.tuckers.build(:title => "Foo", :latitude =>   90.0).should be_valid
      @user.tuckers.build(:title => "Foo", :latitude =>   35.0).should be_valid
    end
    
    it "should reject longitudes outside [-180, 180]" do
      @user.tuckers.build(:title => "Foo", :longitude => -300.0).should_not be_valid
      @user.tuckers.build(:title => "Foo", :longitude =>  190.0).should_not be_valid
      @user.tuckers.build(:title => "Foo", :longitude => -180.0).should be_valid
      @user.tuckers.build(:title => "Foo", :longitude =>  180.0).should be_valid
      @user.tuckers.build(:title => "Foo", :longitude =>   35.0).should be_valid
    end
  end
  
  describe "from_users_followed_by" do
    
    before(:each) do
      @other_user = Factory(:user, :email => Factory.next(:email))
      @third_user = Factory(:user, :email => Factory.next(:email))
      
      @user_tucker = @user.tuckers.create!(:title => "Foo")
      @other_tucker = @other_user.tuckers.create!(:title => "bar")
      @third_tucker = @third_user.tuckers.create!(:title => "baz")
      
      @user.follow!(@other_user)
    end
    
    it "should have a from_users_followed_by class method" do
      Tucker.should respond_to(:from_users_followed_by)
    end
    
    it "should include the followed users' tuckers" do
      Tucker.from_users_followed_by(@user).should include(@other_tucker)
    end
    
    it "should include the user's own tuckers" do
      Tucker.from_users_followed_by(@user).should include(@user_tucker)
    end
    
    it "should not include an unfollowed user's tuckers" do
      Tucker.from_users_followed_by(@user).should_not include(@third_tucker)
    end
  end
  
  describe "geocoding" do
  
    it "should assign correct coordinates" do
      lat = 40.7782667
      lng = -73.9698797
      @tucker = @user.tuckers.create!(@attr)
      @tucker.latitude.should be_within(0.0001).of(lat)
      @tucker.longitude.should be_within(0.0001).of(lng)
    end
  end
end
