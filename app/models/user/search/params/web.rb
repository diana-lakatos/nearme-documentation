class User::Search::Params::Web < User::Search::Params
  attr_reader :sort, :order, :lg_custom_attributes, :lg_custom_attributes, :category_ids

  def initialize(options, instance_profile_type)
    super

    @instance_profile_type = instance_profile_type
    @sort = (@options[:sort].presence || 'relevance').inquiry
    @order = (@options[:order].presence || 'ASC')

    @lg_custom_attributes = @options[:lg_custom_attributes] || {}
    @lg_custom_attributes.each do |key, value|
      @lg_custom_attributes[key] = (String === value ? value.split(',') : value).map(&:strip)
    end

    @category_ids = get_category_ids
  end

  def get_category_ids
    categories = Category.where(id: @options[:category_ids].split(',')) if @options[:category_ids]
    if categories.present?
      if @instance_profile_type.category_search_type == 'OR'
        parent_ids = categories.map(&:parent_id)
        categories.map do |category|
          unless parent_ids.include?(category.id)
            category.self_and_descendants.map(&:id)
          end
        end.flatten.compact
      else
        categories.map(&:id)
      end
    else
      []
    end
  end
end

