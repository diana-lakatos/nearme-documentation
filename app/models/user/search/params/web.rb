# frozen_string_literal: true
class User::Search::Params::Web < User::Search::Params
  attr_reader :sort, :order, :lg_custom_attributes, :lg_custom_attributes, :category_ids

  def initialize(options, instance_profile_type, aggregations = [])
    super(options)

    @instance_profile_type = instance_profile_type
    @sort = (@options[:sort].presence || 'relevance').inquiry
    @order = (@options[:order].presence || 'ASC')

    @lg_custom_attributes = @options[:lg_custom_attributes] || {}
    @lg_custom_attributes.each do |key, value|
      @lg_custom_attributes[key] = (String === value ? value.split(',') : value).map(&:strip)
    end

    @category_ids = get_category_ids
    @aggregations = aggregations
  end

  def get_category_ids
    categories = Category.where(id: @options[:category_ids].split(',')) if @options[:category_ids]
    if categories.present?
      if @instance_profile_type.category_search_type == 'OR'
        parent_ids = categories.map(&:parent_id)
        categories.map do |category|
          category.self_and_descendants.map(&:id) unless parent_ids.include?(category.id)
        end.flatten.compact
      else
        categories.map(&:id)
      end
    else
      []
    end
  end

  def params
    @options
  end

  def to_liquid
    SearchFormDrop.new(self)
  end

  class SearchFormDrop < BaseDrop
    delegate :category_ids, to: :source

    def params
      source.params.deep_stringify_keys
    end

    # TODO: fetch data from ES aggragations WIP
    def dictionary
      # aggregations for the win
      { states: custom_attribute_values('states') }.deep_stringify_keys
    end

    def custom_attribute_values(key)
      CustomAttributes::CustomAttribute.find_by(name: key).valid_values
    end

    def properties
    end
  end
end
