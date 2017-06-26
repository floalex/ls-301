class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
  before_action :require_same_user, only: [:edit, :update]
  
  def show
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    
    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "You have registered succesfully!"
      redirect_to root_path
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      flash[:notice] = "Your profile has been updated."
      redirect_to root_path
    else
      render :new
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:username, :password)
  end
  
  def set_user
    @user = User.find_by(slug: params[:id])
  end
  
  def require_same_user
    if current_user != @user
      access_denied
    end
  end
end