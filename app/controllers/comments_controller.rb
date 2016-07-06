class CommentsController < ApplicationController

  before_filter :find_commentable

  def index
    @comments = @commentable.comments.order("created_at DESC").paginate(page: params[:page], per_page: 10)
  end

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.creator = current_user
    @comment.save
  end

  def destroy
    @comment = @commentable.comments.find(params[:id])
    unless @comment.can_remove?(current_user, @commentable) && @comment.destroy
      return render nothing: true
    end
  end

  private

  def find_commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/ && ["listing_id", "activity_feed_event_id"].include?(name)
        if $1 == 'listing'
          @commentable = Transactable.find(value)
        else
          @commentable = $1.classify.constantize.find(value)
        end
      end
    end
    nil
  end

  def comment_params
    params.require(:comment).permit(secured_params.comment)
  end
end
