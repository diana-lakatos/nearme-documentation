class Spree::Product::Search::Params::Web < Spree::Product::Search::Params
  attr_reader :sort, :category_ids, :lg_custom_attributes

  def initialize(options)
    super
    @sort = (@options[:sort].presence || 'name').inquiry
    @category_ids = @options[:category_ids]
    @lg_custom_attributes = @options[:lg_custom_attributes] || {}
    @lg_custom_attributes.each do |key, value|
      @lg_custom_attributes[key] = (String === value ? value.split(',') : value).map(&:strip)
    end
  end

end

