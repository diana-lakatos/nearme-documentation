class Registrations::BuyersController < ApplicationController

  def show
    @theme_name = 'buy-sell-theme'
    @user = User.find params[:user_id]
    @company = @user.companies.first
    if @company.present? && buyable?
      @products = @company.products.paginate(page: params[:products_page], per_page: 8)
    end
    if @company.present? && bookable?
      @listings = @company.listings.includes(:location).paginate(page: params[:services_page], per_page: 8)
    end
    if RatingSystem.active.any?
      @reviews_count = Review.about_seller(@user).count
      @reviews_about_buyer_count = Review.about_buyer(@user).count
      @reviews_left_by_seller_count = Review.left_by_seller(@user).count
      @reviews_left_by_buyer_count = Review.left_by_buyer(@user).count
      @total_reviews_count = @reviews_count + @reviews_about_buyer_count + @reviews_left_by_seller_count + @reviews_left_by_buyer_count
    end
  end

end
