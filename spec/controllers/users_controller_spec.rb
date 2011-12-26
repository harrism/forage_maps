require 'spec_helper'

describe UsersController do
  render_views
  
  describe "GET :index" do
    
    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end
    
    describe "for signed-in users" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :name => "Bob", :email => "another@example.com")
        third = Factory(:user,  :name => "Ben", :email => "another@example.net")
        
        @users = [@user, second, third]
        30.times do
          @users << Factory(:user, :email => Factory.next(:email))
        end
      end
      
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have the right title" do
        get :index
        response.body.should have_selector("title", :content => "All Users")
      end
      
      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.body.should have_selector("li", :content => user.name)
        end
      end
      
      it "should paginate users" do
        get :index
        response.body.should have_selector("div.pagination")
        response.body.should have_selector("span.disabled", :content => "Previous")
        response.body.should have_selector("a", :href => "/users?page=2",
                                                :content => "2")
        response.body.should have_selector("a", :href => "/users?page=2",
                                                :content => "Next")
      end
    end
  end
         
  describe "GET :show" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should be succcessful" do
      get :show, :id => @user
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    
    it "should have the right title" do
      get :show, :id => @user
      response.body.should have_selector("title", :content => @user.name)
    end
    
    it "should include the users's name" do
      get :show, :id => @user
      response.body.should have_selector("h1", :content => @user.name)
    end
    
    it "should have a profile image" do
      get :show, :id => @user
      response.body.should have_selector("h1>img", :class => "gravatar")
    end
    
    it "should show the users tuckers" do
      t1 = Factory(:tucker, :user => @user, :title => "Foo Bar")
      t2 = Factory(:tucker, :user => @user, :title => "Baz quux")
      get :show, :id => @user
      response.body.should have_selector("span.title", :content => t1.title)
      response.body.should have_selector("span.title", :content => t2.title)
    end
    
    it "should paginate the users tuckers" do
      50.times do |t|
        Factory(:tucker, :user => @user, :title => "Tucker #{t}")
      end
      get :show, :id => @user
      response.body.should have_selector("div.pagination")
      response.body.should have_selector("span.disabled", :content => "Previous")
      response.body.should have_selector("a", :href => "/users/#{@user.id}?page=2",
                                              :content => "2")
      response.body.should have_selector("a", :href => "/users/#{@user.id}?page=2",
                                              :content => "Next")
    end
  end

  describe "GET :new" do
    
    describe "for non-signed-in users" do
      
      it "should be successful" do
        get :new
        response.should be_success
      end
    
      it "should have the right title" do
        get :new
        response.body.should have_selector("title", :content => "Sign up")
      end
    
      it "should have a name field" do
        get :new
        response.body.should have_selector("input[name='user[name]'][type='text']")
      end
    
      it "should have an email field" do
        get :new
        response.body.should have_selector("input[name='user[email]'][type='text']")
      end
    
      it "should have a password field" do
        get :new
        response.body.should have_selector("input[name='user[password]'][type='password']")
      end
    
      it "should have a password confirmation field" do
        get :new
        response.body.should have_selector("input[name='user[password_confirmation]'][type='password']")
      end
    end
    
    describe "for signed-in users" do
      
      it "should redirect to the root path" do
        test_sign_in(Factory(:user))
        get :new
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe "POST :create" do
    
    describe "for non-signed-in users" do
      
      describe "failure" do
      
        before(:each) do
          @attr = { :name => "", :email => "", :password => "",
                    :password_confirmation => "" }
        end
      
        it "should not create a user" do
          lambda do 
            post :create, :user => @attr
          end.should_not change(User, :count)
        end
      
        it "should have the right title" do
          post :create, :user => @attr
          response.body.should have_selector("title", :content => "Sign up")
        end 
      
        it "should render the 'new' page" do
          post :create, :user => @attr
          response.should render_template('new')
        end
      end
    
      describe "success" do
      
        before(:each) do
          @attr = { :name => "New User", :email => "user@example.com",
                    :password => "foobar", :password_confirmation => "foobar" }
        end
      
        it "should create a user" do
          lambda do
            post :create, :user => @attr
          end.should change(User, :count).by(1)
        end
      
        it "should sign the user in" do
          post :create, :user => @attr
          controller.should be_signed_in
        end
      
        it "should redirect to the user show page" do
          post :create, :user => @attr
          response.should redirect_to(user_path(assigns(:user)))
        end
      
        it "should have a welcome message" do
          post :create, :user => @attr
          flash[:success].should =~ /welcome to ForageMaps/i
        end
      
      end
    end
    
    describe "for signed-in users" do
      
      it "should redirect to the root path" do
        test_sign_in(Factory(:user))
        post :create, :user => { :name => "New User", :email => "user@ex.com",
                                 :password => "foo", :passwod => "bar" }
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end
    
    it "should have the right title" do
      get :edit, :id => @user
      response.body.should have_selector("title", :content => "Edit user")
    end
    
    it "should have a link to change the avatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.body.should have_selector("a", :href => gravatar_url,
                                         :content => "change")
    end
  end
  
  describe "PUT 'update'" do
    
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    describe "failure" do
      
      before(:each) do
        @attr = { :email => "", :name => "", :password => "",
                  :password_confirmation => "" }
      end
      
      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end
      
      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.body.should have_selector("title", :content => "Edit user")
      end
    end
    
    describe "success" do
      
      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz" }
      end
      
      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should == @attr[:name]
        @user.email.should == @attr[:email]
      end
      
      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end
      
      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end
  
  describe "authentication of edit/update actions" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "for non-signed-in users" do
      
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end
      
      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end
    
    describe "for signed-in users" do
      
      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end
      
      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      
      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end 
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end
    
    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end
  
    describe "as an admin-user" do
      
      before(:each) do
        @admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(@admin)
      end
      
      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end
      
      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
      
      it "should not destroy the user if it is the current admin" do
        lambda do
          delete :destroy, :id => @admin.id
        end.should_not change(User, :count)
        response.should redirect_to(users_path)
        flash[:failure].should =~ /admin cannot destroy self/i
      end
    end
  end
  
  describe "follow pages" do
    
    describe "when not signed in" do
      
      it "should protect 'following'" do
        get :following, :id => 1
        response.should redirect_to(signin_path)
      end
      
      it "should protect 'followers'" do
        get :followers, :id => 1
        response.should redirect_to(signin_path)
      end
    end
    
    describe "when signed in" do
      
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :email => Factory.next(:email))
        @user.follow!(@other_user)
      end
      
      it "should show user following" do
        get :following, :id => @user
        response.body.should have_selector("a", :href => user_path(@other_user),
                                                :content => @other_user.name)
      end
      
      it "should show user followers" do
        get :followers, :id => @other_user
        response.body.should have_selector("a", :href => user_path(@user),
                                                :content => @user.name)
      end
    end
  end 
end
