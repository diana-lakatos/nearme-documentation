class Spree::Product::Search::Params
  attr_reader :options

  def initialize(options)
    @options = options.respond_to?(:deep_symbolize_keys) ? options.deep_symbolize_keys : options.symbolize_keys
  end

  def query
    @options[:query] || @options[:q] || @options[:address] || @options[:loc]
  end
end
