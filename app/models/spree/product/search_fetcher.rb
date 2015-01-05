class Spree::Product::SearchFetcher
  extend ::NewRelic::Agent::MethodTracer

  def initialize(filters = {})
    @filters = filters
  end

  def products
    order = @filters[:sort].blank? ? nil : "#{@filters[:sort]} ASC"
    @products = filtered_products.order(order)
    if !@filters[:taxon].blank? || !@filters[:query].blank?
      @products = @products.in_taxon(taxon) if taxon.present?
      @products = @products.like_any([:name, :description], @filters[:query].split) unless @filters[:query].blank?
    else
      @products = @products.where('1=0')
    end
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
