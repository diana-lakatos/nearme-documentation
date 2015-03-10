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
      when 'reviews_left_by_seller' then @user.reviews.for_buyer.both_sides_reviewed_for('seller')
      when 'reviews_left_by_buyer' then @user.reviews.for_seller_and_product.both_sides_reviewed_for('buyer')
    end
  end

  def rating_questions_by_role
    subject = if @params[:option] == 'reviews_about_buyer'
      @platform_context.instance.lessee
    elsif @params[:option] == 'reviews_about_seller'
      @platform_context.instance.lessor
    end

    RatingSystem.active_with_subject(subject).try(:rating_questions)
  end
end