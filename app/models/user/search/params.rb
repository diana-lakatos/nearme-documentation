# frozen_string_literal: true
require 'active_support/core_ext'

class User::Search::Params
  def initialize(options)
    @options = options.deep_symbolize_keys
  end

  def query
    @options[:q] || @options[:query]
  end

  def keyword
    @options[:query][0, 200] if @options[:query]
  end
end
