class SessionsController < ApplicationController
  def new
  end
  
  def create
    # where method will return array so need to attach first to get that user
    user = User.where(username: params[:username]).first   # can also use user = User.find_by(username: params[:username])
    
    if user && user.authenticate(params[:password])
      login_users!(user)
    else
      flash[:error] = "There is something wrong with your username or password."
      redirect_to login_path
      # alternative
        # flash.now[:error]
        # render :new
    end
  end
  
  def destroy
    session[:user_id] = nil
    flash[:notice] = "You've logged out."
    redirect_to root_path
  end
  
  private 
    
    def login_users!(user)
      session[:user_id] = user.id
      flash[:notice] = "Welcome, you have logged in."
      redirect_to root_path
    end
    
end