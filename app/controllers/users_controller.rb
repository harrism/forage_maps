class UsersController < ApplicationController
  before_filter :authenticate,  :except => [ :show, :new, :create ]
  before_filter :correct_user,  :only => [ :edit, :update ]
  before_filter :admin_user,    :only => :destroy
  before_filter :not_signed_in, :only => [ :new, :create ]
  
  def index
    @title = "All Users"
    @users = User.paginate(:page => params[:page])
  end
  
  def show
    @user  = User.find(params[:id])
    @tuckers = @user.tuckers.paginate(:page => params[:page])
    @title = @user.name
  end

  def new
    @user = User.new
    @title = "Sign up"
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to ForageMaps!"
      redirect_to @user
    else
      @title = "Sign up"
      @user.password = ""
      @user.password_confirmation = ""
      render 'new'
    end
  end
  
  def edit
    @title = "Edit user"
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      @user.password = ""
      @user.password_confirmation = ""
      render 'edit'
    end
  end
  
  def destroy
    user = User.find(params[:id])
    if user == current_user
      flash[:failure] = "Admin cannot destroy self."
    else
      user.destroy
      flash[:success] = "User destroyed."
    end
    redirect_to users_path
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end
  
  private
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
    
    def not_signed_in
      redirect_to(root_path) unless not signed_in?
    end
end
