require 'spec_helper'

describe "Tuckers" do
  
  before(:each) do
    user = Factory(:user)
    visit signin_path
    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button
  end
  
  describe "creation" do
    
    describe "failure" do
      
      it "should not make a new tucker" do
        lambda do
          visit root_path
          response.should have_selector("textarea#tucker_title")
          fill_in :tucker_title, :with => ""
          click_button
          response.should render_template('pages/home')
          response.should have_selector("div#error_explanation")
        end.should_not change(Tucker, :count)
      end
    end
    
    describe "success" do
      
      it "should make a new tucker" do
        title = "Lorem ipsum"
        description = "dolor sit amet"
        lambda do
          visit root_path
          fill_in :tucker_title, :with => title
          fill_in :tucker_description, :with => description
          click_button
          response.should have_selector("span.title", :content => title)
        end.should change(Tucker, :count).by(1)
      end
    end
  end
end
