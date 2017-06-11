class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :vote]
  before_action :require_user, except: [:index, :show]
  
  def index
    @posts = Post.all.sort_by{ |post| post.total_votes }.reverse
  end
  
  def show
    @comment = Comment.new
  end
  
  def new
    @post = Post.new
  end
  
  def create
    @post = Post.new(post_params)
    @post.creator = current_user
    
    if @post.save
      flash[:notice] = 'New post has been created.'
      redirect_to posts_path
    else
      render :new
    end
  end
  
  def edit   
  end
  
  def update   
    if @post.update(post_params)
      flash[:notice] = 'The post has been updated.'
      redirect_to post_path(@post)
    else
      render :edit
    end
  end
  
  def vote
    vote = Vote.create(voteable: @post, creator: current_user, vote: params[:vote])
    
    # since we dont use form to submit vote, so use valid instead of save here
    if vote.valid?
      flash[:notice] = "Your vote is counted."
    else
      flash[:error] = "You can only vote once on this post."
    end
    
    redirect_to :back
  end
  
  private 
  
    def post_params
      params.require(:post).permit(:title, :url, :description, category_ids: [])
    end
    
    def set_post
      @post = Post.find(params[:id])
    end
end
