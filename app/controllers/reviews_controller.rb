class ReviewsController < ApplicationController

  def index
    if params[:reviewable_parent_type].blank? || params[:object].blank?
      render nothing: true, status: :bad_request
    else
      @reviewable_parent = case params[:reviewable_parent_type]
       when 'Transactable'
         Transactable
       when 'Spree::Product'
         Spree::Product
       when 'User'
         User
       else
         raise NotImplementedError
       end.with_deleted.find(params[:reviewable_parent_id])

       case params[:object]
       when 'product'
         @reviews = @reviewable_parent.reviews
         @average_rating = @reviewable_parent.try(:average_rating)
         @question_average_rating = @reviewable_parent.question_average_rating
       when 'seller'
         @reviews = @reviewable_parent.reviews_about_seller
         @average_rating = @reviewable_parent.seller_average_rating
         @question_average_rating = @reviewable_parent.question_average_rating(@reviews)
       else
         raise NotImplementedError
       end
       @total_reviews = @reviews.length
       @reviews = @reviews.paginate(page: params[:page], total_entries: @total_reviews)
       @rating_questions = RatingSystem.active_with_subject(params[:subject]).try(:rating_questions)
       render json: { tab_content: render_to_string(template: 'reviews/index'), tab_header: render_to_string(partial: 'reviews/tab_header') }
    end
  end

end

