require 'active_support/core_ext'

class User::Search::Params

  def initialize(options, instance_profile_type)
    @options = options.respond_to?(:deep_symbolize_keys) ? options.deep_symbolize_keys : options.symbolize_keys
  end

  def query
    (@options[:q] || @options[:query])
  end

  def keyword
    @options[:query][0, 200] if @options[:query]
  end

end
