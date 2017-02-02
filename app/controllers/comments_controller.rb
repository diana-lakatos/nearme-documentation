# frozen_string_literal: true
class CommentsController < ApplicationController
  before_action :find_commentable

  def index
    @comments = @commentable.comments.order('created_at DESC').paginate(page: params[:page], per_page: 10)
  end

  def show
    @comment = @commentable.comments.find(params[:id])
  end

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.creator = current_user
    return render nothing: true unless @comment.save
    respond_to do |format|
      format.html { render action: :show }
      format.js
    end
  end

  def update
    @comment = @commentable.comments.find(params[:id])
    return render nothing: true unless @comment.can_edit?(current_user, @commentable) && @comment.update(comment_params)
  end

  def destroy
    @comment = @commentable.comments.find(params[:id])
    return render nothing: true unless @comment.can_remove?(current_user, @commentable) && @comment.destroy
  end

  private

  def find_commentable
    params.each do |name, value|
      next unless name =~ /(.+)_id$/ && %w(transactable_id listing_id activity_feed_event_id).include?(name)
      @commentable = if Regexp.last_match(1) == 'listing' || Regexp.last_match(1) == 'transactable'
                       Transactable.find(value)
                     else
                       Regexp.last_match(1).classify.constantize.find(value)
                     end
    end
    nil
  end

  def comment_params
    params.require(:comment).permit(secured_params.comment)
  end
end
