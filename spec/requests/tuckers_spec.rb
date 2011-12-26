require 'spec_helper'

describe "Tuckers" do
  
  before(:each) do
    user = Factory(:user)
    integration_sign_in(user)
  end
  
  describe "creation" do
    
    describe "failure" do
      
      it "should not make a new tucker" do
        lambda do
          visit root_path
          page.should have_selector("input#tucker_title")
          fill_in "tucker_title", :with => ""
          click_button "Submit"
          response.should_not have_content("Tucker created!")
          page.should have_selector("div#error_explanation")
        end.should_not change(Tucker, :count)
      end
    end
    
    describe "success" do
      
      it "should make a new tucker" do
        title = "Lorem ipsum"
        description = "dolor sit amet"
        lambda do
          visit root_path
          fill_in "tucker_title", :with => title
          fill_in "tucker_description", :with => description
          click_button "Submit"
          page.should have_content("Tucker created!")
          page.should have_content(title)
          page.should have_content(description)
          page.should have_selector("span.title", :content => title)
        end.should change(Tucker, :count).by(1)
      end
    end
  end
end
