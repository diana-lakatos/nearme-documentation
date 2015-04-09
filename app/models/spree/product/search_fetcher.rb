class Spree::Product::SearchFetcher
  extend ::NewRelic::Agent::MethodTracer

  def initialize(filters = {})
    @filters = filters
  end

  def products
    order = Spree::Product.column_names.include?(@filters[:sort]) ? "#{@filters[:sort]} ASC" : nil
    @products = filtered_products.order(order)
    @products = @products.search_by_query([:name, :description, :extra_properties], @filters[:query]) unless @filters[:query].blank?
    @products = @products.in_taxon(taxon) if taxon.present?
    (@filters[:custom_attributes] || {}).each do |field_name, values|
      next if values.blank? || values.all?(&:blank?)
      @products = @products.filtered_by_custom_attribute(field_name, values)
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
