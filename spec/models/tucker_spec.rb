require 'spec_helper'

describe Tucker do
  
  before(:each) do
    @user = Factory(:user)
    @attr = {
      :title => "A Food",
      :description => "Growing somewhere.",
      :lat => 40.0,
      :lng => 0.0
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
        
    it "should reject long titles" do
      @user.tuckers.build(:title => "a" * 51).should_not be_valid
    end
    
    it "should reject long descriptions" do
      @user.tuckers.build(:description => "a" * 501).should_not be_valid
    end
    
    it "should have lat and lng of 0.0 by default" do
      t = @user.tuckers.build(:title => "Foo")
      t.lat.should == 0.0
      t.lng.should == 0.0
    end
    
    it "should reject latitudes outside [-90, 90]" do
      @user.tuckers.build(:title => "Foo", :lat => -100.0).should_not be_valid
      @user.tuckers.build(:title => "Foo", :lat =>  150.0).should_not be_valid
      @user.tuckers.build(:title => "Foo", :lat =>  -90.0).should be_valid
      @user.tuckers.build(:title => "Foo", :lat =>   90.0).should be_valid
      @user.tuckers.build(:title => "Foo", :lat =>   35.0).should be_valid
    end
    
    it "should reject longitudes outside [-180, 180]" do
      @user.tuckers.build(:title => "Foo", :lng => -300.0).should_not be_valid
      @user.tuckers.build(:title => "Foo", :lng =>  190.0).should_not be_valid
      @user.tuckers.build(:title => "Foo", :lng => -180.0).should be_valid
      @user.tuckers.build(:title => "Foo", :lng =>  180.0).should be_valid
      @user.tuckers.build(:title => "Foo", :lng =>   35.0).should be_valid
    end
  end
end
