require 'spec_helper'

describe SessionsController do
  render_views
  
  describe "GET 'new'" do
  
    before(:each) do
      get :new
    end
  
    it "should be successful" do
      response.should be_success
    end
    
    it "should have the right title" do
      response.body.should have_selector("title", :content => "Sign in")
    end
    
    it "should have a forgotten password link" do
      response.body.should have_selector("a", :content => "forgotten password?")
    end
    
    it "should have a 'remember me' check box" do
      response.body.should have_selector("label", :content => "Remember me")
      response.body.should have_selector("input", :id => "remember_me")
    end
  end
  
  describe "POST 'create'" do
    
    describe "invalid signin" do
      
      before(:each) do
        @attr = { :email => "email@example.com", :password => "invalid" }
      end
    
      it "should re-render the new page" do
        post :create, :session => @attr
        response.should render_template('new')
      end
    
      it "should have the right title" do
        post :create, :session => @attr
        response.body.should have_selector("title", :content => "Sign in")
      end
    
      it "should have a flash.now message" do
        post :create, :session => @attr
        flash.now[:error].should =~ /invalid/i
      end
    end
    
    describe "with valid email and password" do
      
      before(:each) do
        @user = Factory(:user)
        @attr = { :email => @user.email, :password => @user.password }
      end
      
      it "should sign the user in" do
        post :create, :session => @attr
        controller.current_user.should == @user
        controller.should be_signed_in
      end
      
      it "should redirect to the user show page" do
        post :create, :session => @attr
        response.should redirect_to(user_path(@user))
      end
      
      it "should store a valid auth_token cookie" do
        post :create, :session => @attr
        cookies[:auth_token].should_not be_nil
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    
    it "should sign a user out" do
      test_sign_in(Factory(:user))
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end
end
