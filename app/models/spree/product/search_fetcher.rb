class Spree::Product::SearchFetcher
  extend ::NewRelic::Agent::MethodTracer

  def initialize(filters = {})
    @filters = filters
  end

  def products
    order = Spree::Product.column_names.include?(@filters[:sort]) ? "#{@filters[:sort]} ASC" : nil
    @products = filtered_products.order(order)
    @products = @products.search_by_query([:name, :description, :extra_properties], @filters[:query]) unless @filters[:query].blank?
    if categories.present?
      if PlatformContext.current.instance.category_search_type == "AND"
        @products = @products.
          joins(:categories_categorizables).
          where(categories_categorizables: {category_id: category_ids}).
          group('spree_products.id').having("count(categories_categorizables.category_id) >= #{category_ids.size}")
      else
        @products = @products.joins(:categories_categorizables).where(categories_categorizables: {category_id: category_ids}).distinct
      end
    end
    (@filters[:custom_attributes] || {}).each do |field_name, values|
      next if values.blank? || values.all?(&:blank?)
      @products = @products.filtered_by_custom_attribute(field_name, values)
    end
    @products
  end

  private

  def categories
    @categories ||= Category.where(id: @filters[:category_ids].split(',')) unless @filters[:category_ids].blank?
  end

  def category_ids
    categories.map { |c| c.self_and_descendants.map(&:id) }.flatten.uniq
  end

  def filtered_products
    Spree::Product.searchable
  end
end
