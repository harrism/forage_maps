class TuckersController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy]
  before_filter :authorized_user, :only => :destroy
  
  def create
    @tucker = current_user.tuckers.build(params[:tucker])
    if @tucker.save
      flash[:success] = "Tucker created!"
      redirect_to root_path
    else
      @feed_items = []
      render 'pages/home'
    end
  end
  
  def destroy
    @tucker.destroy
    redirect_back_or root_path
  end
  
  private
  
    def authorized_user
      @tucker = current_user.tuckers.find_by_id(params[:id])
      redirect_to root_path if @tucker.nil?
    end
end