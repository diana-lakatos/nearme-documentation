class Spree::Product::SearchFetcher
  extend ::NewRelic::Agent::MethodTracer

  def initialize(filters = {})
    @filters = filters
  end

  def products
    @products = filtered_products.order(@filters[:sort])
    @products = @products.in_taxon(taxon) if taxon.present?
    @products = @products.like_any([:name, :description], @filters[:query].split) unless @filters[:query].blank?
    @products
  end

  private

  def taxon
    @taxon ||= Spree::Taxon.find_by!(permalink: @filters[:taxon]) unless @filters[:taxon].blank?
  end

  def filtered_products
    Spree::Product.searchable
  end
end
