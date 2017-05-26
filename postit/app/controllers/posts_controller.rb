class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
  
  def show
    @post = Post.find(params[:id])
  end
  
  def new
    @post = Post.new
  end
  
  def create
    @post = Post.new(post_params)
    @post.creator = User.first ##TODO: need to change once have authentication
    
    if @post.save
      flash[:notice] = 'New post has been created.'
      redirect_to posts_path
    else
      render :new
    end
  end
  
  def edit
    @post = Post.find(params[:id])
  end
  
  def update
    @post = Post.find(params[:id])
    
    if @post.update(post_params)
      flash[:notice] = 'The post has been updated.'
      redirect_to post_path(@post)
    else
      render :edit
    end
  end
  
  private 
  
    def post_params
      params.require(:post).permit(:title, :url, :description)
    end
end
