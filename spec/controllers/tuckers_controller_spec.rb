require 'spec_helper'

describe TuckersController do
  render_views
  
  describe "access control" do
    
    it "should deny access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end
    
    it "should deny access to 'destroy'" do
      delete :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
  end
  
  describe "POST 'create'" do
    
    before(:each) do
      @user = test_sign_in(Factory(:user))
    end
    
    describe "failure" do
      
      before(:each) do
        @attr = { :title => "", :description => "", :address => "" }
      end
      
      it "should not create a tucker" do
        lambda do
          post :create, :tucker => @attr
        end.should_not change(Tucker, :count)
      end
      
      it "should render the home page" do
        post :create, :tucker => @attr
        response.should render_template('pages/home')
      end
    end
    
    describe "success" do
      
      before(:each) do
        @attr = { :title => "Foo", :description => "Bar" }
      end
      
      it "should create a tucker" do
        lambda do
          post :create, :tucker => @attr
        end.should change(Tucker, :count).by(1)
      end
      
      it "should redirect to the home page" do
        post :create, :tucker => @attr
        response.should redirect_to(root_path)
      end
      
      it "should have a flash message" do
        post :create, :tucker => @attr
        flash[:success].should =~ /tucker created/i
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    
    describe "for an unauthorized user" do
      
      before(:each) do
        @user = Factory(:user)
        wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(wrong_user)
        @tucker = Factory(:tucker, :user => @user)
      end
      
      it "should deny access" do
        delete :destroy, :id => @tucker
        response.should redirect_to(root_path)
      end
    end
    
    describe "for an authorized user" do
      
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @tucker = Factory(:tucker, :user => @user)
      end
      
      it "should destroy the tucker" do
        lambda do
          delete :destroy, :id => @tucker
        end.should change(Tucker, :count).by(-1)
      end
    end
  end
end