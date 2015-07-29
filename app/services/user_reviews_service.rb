class UserReviewsService
  def initialize(user, platform_context, params)
    @user = user
    @platform_context = platform_context
    @params = params
  end

  def reviews_by_role
    case @params[:option]
      when 'reviews_about_seller' then @user.reviews_about_seller
      when 'reviews_about_buyer' then @user.reviews_about_buyer
      when 'reviews_left_by_seller' then Review.both_sides_reviewed_for(RatingConstants::SELLER, @user.id)
      when 'reviews_left_by_buyer' then Review.both_sides_reviewed_for(RatingConstants::BUYER, @user.id)
    end
  end

  def rating_questions_by_role
    subject = if @params[:option] == 'reviews_about_buyer'
      RatingConstants::GUEST
    elsif @params[:option] == 'reviews_about_seller'
      RatingConstants::HOST
    end

    RatingSystem.active_with_subject(subject).try(:rating_questions)
  end
end