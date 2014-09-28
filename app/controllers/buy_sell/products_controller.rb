class BuySell::ProductsController < ApplicationController

  def show
    begin
      @product = Spree::Product.searchable.friendly.find(params[:id]).decorate
      @product_properties = @product.product_properties.includes(:property)
    rescue ActiveRecord::RecordNotFound
      raise Transactable::NotFound
    end
  end
end
