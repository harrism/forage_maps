require 'spec_helper'

describe PasswordResetsController do
  render_views

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    
    it "should have the right title" do
      get 'new'
      response.body.should have_selector("title", :content => "Reset Password")
    end
  end
  
  describe "POST 'create'" do
      
    before(:each) do
      @attr = { :email => "email@example.com" }
    end
    
    it "should redirect to the root URL" do
      post :create, :session => @attr
      response.should redirect_to(root_url)
    end
    
    it "should have a notice message" do
      post :create, :session => @attr
      flash[:notice].should =~ /Email sent/i
    end
  end
end
