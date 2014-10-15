class Spree::Product::SearchFetcher
  extend ::NewRelic::Agent::MethodTracer

  def initialize(filters = {})
    @filters = filters
  end

  def products
    @products = filtered_products
    @products.like_any([:name, :description], @filters[:query].split)
  end

  private

  def filtered_products
    @products_scope = Spree::Product.searchable
    @products_scope
  end
end
