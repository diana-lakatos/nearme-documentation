class BuySellMarket::ProductsController < ApplicationController

  def show
    begin
      @product = Spree::Product.searchable.friendly.find(params[:id]).decorate
      @product_properties = @product.product_properties.includes(:property)
      @product.track_impression(request.remote_ip)
    rescue ActiveRecord::RecordNotFound
      raise Transactable::NotFound
    end
  end
end
