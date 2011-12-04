# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end
  
  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end
  
  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  describe "password validations" do
    
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end
    
    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end
    
    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end
    
    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end
  
  describe "password encryption" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have a password digest attribute" do
      @user.should respond_to(:password_digest)
    end
    
    it "should set the password digest" do
      @user.password_digest.should_not be_blank
    end
        
    describe "authenticate method" do

      it "should return false on email/password mismatch" do
        @user.authenticate("wrongpass").should be_false
      end
            
      it "should return true on password match" do
        @user.authenticate(@attr[:password]).should be_true
      end
    end
  end
  
  describe "admin attribute" do
    
    before(:each) do
      @user = User.create(@attr)
    end
    
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end
    
    it "should not be an admin by default" do
      @user.should_not be_admin
    end
    
    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
  
  describe "tucker associations" do
    
    before(:each) do
      @user = User.create(@attr)
      @t1 = Factory(:tucker, :user => @user, :created_at => 1.day.ago)
      @t2 = Factory(:tucker, :user => @user, :created_at => 1.hour.ago)
    end
    
    it "should have a tuckers attribute" do
      @user.should respond_to(:tuckers)
    end
    
    it "should have the right tuckers in the right order" do
      @user.tuckers.should == [@t2, @t1]
    end
    
    describe "status feed" do
      
      it "should have a feed" do
        @user.should respond_to(:feed)
      end
      
      it "should include the user's tuckers" do
        @user.feed.include?(@t1).should be_true
        @user.feed.include?(@t2).should be_true
      end
      
      it "should not include a different user's tuckers" do
        t3 = Factory(:tucker,
                     :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.include?(t3).should be_false
      end
    end
    
    describe "status feed" do
      
      it "should have a feed" do
        @user.should respond_to(:feed)
      end
      
      it "should include the user's tuckers" do
        @user.feed.should include(@t1)
        @user.feed.should include(@t2)
      end
      
      it "should not include a different user's tuckers" do
        t3 = Factory(:tucker, 
                     :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.should_not include(t3)
      end
      
      it "should include the tuckers of followed users" do
        followed = Factory(:user, :email => Factory.next(:email))
        t3 = Factory(:tucker, :user => followed)
        @user.follow!(followed)
        @user.feed.should include(t3)
      end
    end
  end
  
  describe "relationships" do
    
    before :each do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end
    
    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end
    
    it "should have a following method" do
      @user.should respond_to(:following)
    end
    
    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end
    
    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end
    
    it "should have an unfollow! method" do
      @user.should respond_to(:unfollow!)
    end
    
    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end
    
    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end
    
    it "should have a followers method" do
      @user.should respond_to(:followers)
    end
    
    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end
end
