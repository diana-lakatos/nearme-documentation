# frozen_string_literal: true
class Registrations::SellersController < ApplicationController
  def show
    @theme_name = 'buy-sell-theme'
    @user = User.find params[:user_id]
    @company = @user.companies.first
    if @company.present?
      @listings = @company.listings.searchable.includes(:location).paginate(page: params[:services_page], per_page: 8)
    end

    @reviews_counter = ReviewAggregator.new(@user) if RatingSystem.active.any?
  end
end
