class UserReviewsService
  def initialize(user, params)
    @user = user
    @params = params
  end

  def reviews_by_role
    case @params[:option]
    when 'reviews_about_seller' then Review.about_seller(@user)
    when 'reviews_about_buyer' then Review.about_buyer(@user)
    when 'reviews_left_by_seller' then  Review.left_by_seller(@user)
    when 'reviews_left_by_buyer' then Review.left_by_buyer(@user)
    else
      fail NotImplementedError
    end
  end

  def average_rating
    case @params[:option]
    when 'reviews_about_seller' then @user.seller_average_rating
    when 'reviews_about_buyer' then @user.buyer_average_rating
    when 'reviews_left_by_seller' then @user.left_by_seller_average_rating
    when 'reviews_left_by_buyer' then @user.left_by_buyer_average_rating
    else
      fail NotImplementedError
    end
  end
end
