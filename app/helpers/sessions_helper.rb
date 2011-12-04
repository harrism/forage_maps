module SessionsHelper

  def sign_in(user)
    if params[:remember_me]
      cookies.permanent[:auth_token] = user.auth_token
    else
      cookies[:auth_token] = user.auth_token  
    end
    current_user = user
    @current_user = user
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||= User.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
  end
  
  def signed_in?
    !current_user.nil?
  end
  
  def sign_out
    current_user = nil
    @current_user = nil
    cookies.delete(:auth_token)
  end
  
  def current_user?(user)
    user == current_user
  end
  
  def authenticate
    deny_access unless signed_in?
  end
  
  def deny_access
    store_location
    redirect_to signin_path, :notice => "Please sign in to access this page."
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end
  
  private
    
    def store_location
      session[:return_to] = request.fullpath
    end
    
    def clear_return_to
      session[:return_to] = nil
    end
end
