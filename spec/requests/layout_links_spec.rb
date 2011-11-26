require 'spec_helper'

describe "LayoutLinks" do

  it "should have a Home page at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end

  it "should have a Contact page at '/contact'" do
    get '/contact'
    response.should have_selector('title', :content => "Contact")
  end

  it "should have an About page at '/about'" do
    get '/about'
    response.should have_selector('title', :content => "About")
  end
  
  it "should have a Help page at '/help'" do
    get '/help'
    response.should have_selector('title', :content => "Help")
  end
  
  it "should have a Sign up page at '/signup'" do
    get '/signup'
    response.should have_selector('title', :content => "Sign up")
  end
  
  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    response.should have_selector('title', :content => "About")
    click_link "Help"
    response.should have_selector('title', :content => "Help")
    click_link "Contact"
    response.should have_selector('title', :content => "Contact")
    click_link "Home"
    response.should have_selector('title', :content => "Home")
    click_link "Sign up now!"
    response.should have_selector('title', :content => "Sign up")
  end
    
  describe "when not signed in" do
    it "should have a signin link" do
      visit root_path
      response.should have_selector("a", :href => signin_path,
                                         :content => "Sign in")
    end
  end
  
  describe "when signed in" do
      
    before(:each) do
      @user = Factory(:user)
      integration_sign_in(@user)
    end
    
    describe "as admin" do
      
      it "should have delete links on the users index page" do
        @user.toggle!(:admin)
        visit users_path
        response.should have_selector("a", :href => user_path(:id => @user),
                                           :content => "delete")
      end
    end
    
    describe "as non-admin" do
      
      it "should not have delete links on the users index page" do
        visit users_path
        response.should_not have_selector("a", :href => user_path(:id => @user),
                                               :content => "delete")
      end
    end
    
    it "should have a signout link" do
      visit root_path
      response.should have_selector("a", :href => signout_path,
                                         :content => "Sign out")
    end
    
    it "should have a profile link" do
      visit root_path
      response.should have_selector("a", :href => user_path(@user),
                                         :content => "Profile")
    end
    
    it "should have a user sidebar with user info" do
      t1 = Factory(:tucker, :user => @user, :title => "Foo Bar")
      visit root_path
      response.should have_selector("td.sidebar div.user_info")
      response.should have_selector("a", :href => user_path(@user),
                                         :content => @user.name)
      response.should have_selector("a", :href => user_path(@user),
                                         :content => "1 tucker")
      t2 = Factory(:tucker, :user => @user, :title => "Baz quux")
      visit root_path
      response.should have_selector("a", :href => user_path(@user),
                                         :content => "2 tuckers")
    end
    
    it "should have delete links next to the user's posts" do
      t1 = Factory(:tucker, :user => @user, :title => "Foo Bar")
      visit root_path
      response.should have_selector("a", :href => tucker_path(t1),
                                         :content => "delete")
    end
    
    it "should not have delete links next to other users' posts" do
      other_user = Factory(:user, :email => "another@foragemaps.com")
      t1 = Factory(:tucker, :user => other_user, :title => "Foo Bar")
      visit root_path
      response.should_not have_selector("a", :href => tucker_path(t1),
                                             :content => "delete")
    end
  end
end
