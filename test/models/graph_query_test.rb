# frozen_string_literal: true
require 'test_helper'

class GraphQueryTest < ActiveSupport::TestCase
  test 'invalid query' do
    query = GraphQuery.new(query_string: 'invalid query')

    assert_not query.valid?
    assert query.errors.include?(:query_string)
  end

  test 'valid query' do
    query = GraphQuery.new(query_string: '{ location { name }}')

    assert query.valid?
    assert_not query.errors.include?(:query_string)
  end
end
