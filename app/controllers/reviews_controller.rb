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

       tab_content, tab_header =
        Rails.cache.fetch(['reviews_view', @reviewable_parent, params[:subject], params[:page]], expires_in: 2.hours) do
         case params[:object]
         when RatingConstants::PRODUCT
           @reviews = @reviewable_parent.reviews
           @average_rating = @reviewable_parent.try(:average_rating)
           @question_average_rating = @reviewable_parent.question_average_rating
         when RatingConstants::SELLER
           @reviews = @reviewable_parent.reviews_about_seller
           @average_rating = @reviewable_parent.seller_average_rating
           @question_average_rating = @reviewable_parent.question_average_rating(@reviews)
         else
           raise NotImplementedError
         end
         @total_reviews = @reviews.length
         @reviews = @reviews.paginate(page: params[:page], total_entries: @total_reviews)
         @rating_questions = RatingSystem.active_with_subject(params[:subject]).try(:rating_questions)
          [
            render_to_string(template: 'reviews/index', formats: [:html], layout: false),
            render_to_string(partial: 'reviews/tab_header', formats: [:html])
          ]
        end
       render json: { tab_content: tab_content, tab_header: tab_header }
    end
  end

end

