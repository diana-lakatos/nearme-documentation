# frozen_string_literal: true
require 'test_helper'

class GraphQueryTest < ActiveSupport::TestCase
  test 'invalid syntax' do
    query = GraphQuery.new(query_string: 'invalid query')

    assert_not query.valid?
    assert query.errors.include?(:query_string)
  end

  test 'query against schema' do
    query = GraphQuery.new(query_string: '{ apples{ oranges }}')

    assert_not query.valid?
    assert query.errors.include?(:query_string)
    assert_equal ["Field 'apples' doesn't exist on type 'RootQuery'"], query.errors[:query_string]
  end

  test 'valid query' do
    query = GraphQuery.new(query_string: '{ location(id: 1) { name }}', name: 'users')

    assert query.valid?
    assert_not query.errors.include?(:query_string)
  end
end
