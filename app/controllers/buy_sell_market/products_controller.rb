class BuySellMarket::ProductsController < ApplicationController
  before_filter :set_product, only: [:show]

  def show
    begin
      @product = @product.decorate
      @product_properties = @product.product_properties.includes(:property)
      @product.track_impression(request.remote_ip)
    rescue ActiveRecord::RecordNotFound
      raise Transactable::NotFound
    end
  end

  private

  def set_product
    @product = Spree::Product.searchable.friendly.find(params[:id])
  end
end
