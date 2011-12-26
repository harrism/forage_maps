require 'spec_helper'

describe "Users" do

  describe "signup" do
    
    describe "failure" do
      
      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         :with => ""
          fill_in "Email",        :with => ""
          fill_in "Password",     :with => ""
          fill_in "Confirmation", :with => ""
          click_button "Sign up"
          page.should have_selector('title', :content => "Sign up")
          page.should have_selector("div#error_explanation")
        end.should_not change(User, :count)
      end
    end
    
    describe "success" do
      
      it "should make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         :with => "Example User"
          fill_in "Email",        :with => "user@example.com"
          fill_in "Password",     :with => "foobar"
          fill_in "Confirmation", :with => "foobar"
          click_button "Sign up"
          page.should have_selector("div.flash.success",
                                    :content => "Welcome")
          page.should have_selector("title", 
                                    :content => "Example User")
        end.should change(User, :count).by(1)
      end
    end
  end
  
  describe "sign in/out" do
    
    describe "failure" do
      it "should not sign a user in" do
        visit signin_path
        fill_in "Email",    :with => ""
        fill_in "Password", :with => ""
        click_button "Sign in"
        page.should have_selector("div.flash.error", :content => "Invalid")
      end
    end
    
    describe "success" do
      it "should sign a user in and out" do
        user = Factory(:user)
        integration_sign_in(user)
        page.should have_selector("h1", :content => user.name)
        page.should have_selector("a", :content => "Sign out")
        #controller.should be_signed_in
        click_link "Sign out"
        #controller.should_not be_signed_in
        page.should have_selector("a", :content => "Sign in")
      end
    end
  end
end
