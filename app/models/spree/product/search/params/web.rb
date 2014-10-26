class Spree::Product::Search::Params::Web < Spree::Product::Search::Params
  attr_reader :attribute_values, :sort, :taxon

  def initialize(options)
    super
    @attribute_values = @options[:attribute_values]
    @sort = (@options[:sort].presence || 'relevance').inquiry
    @taxon = @options[:taxon]
  end

  def attribute_values
    @attribute_values
  end

  def attribute_values_filters
    nil
  end
end
