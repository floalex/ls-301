class CommentsController < ApplicationController
  before_action :require_user
  
  def create
    @post = Post.find_by(slug: params[:post_id])
    @comment = @post.comments.build(params.require(:comment).permit(:body))
    @comment.creator = current_user
    
    if @comment.save
      flash[:notice] = 'Comment was added.'
      redirect_to post_path(@post)
    else
      render 'posts/show'
    end
  end
  
  def vote
    @comment = Comment.find(params[:id])
    @vote = Vote.create(voteable: @comment, creator: current_user, vote: params[:vote])
    
    respond_to do |format|
      format.html do 
        if vote.valid?
          flash[:notice] = "Your vote for the comment was counted."
        else
          flash[:error] = "You can only vote once on this comment."
        end
       
        redirect_to :back
      end
      # for js alert box
      # format.js 
      
      # for flash message
      format.js do 
        if @vote.valid?
          flash.now[:notice] = "Your vote for the comment was counted."
        else
          flash.now[:error] = "You can only vote once on this comment."
        end
      end
    end
  end
end