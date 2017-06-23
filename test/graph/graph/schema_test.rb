# frozen_string_literal: true
require 'test_helper'
require 'graph/schema'

class Graph::SchemaTest < ActiveSupport::TestCase
  test 'execute_query' do
    assert_equal({ 'current_user' => nil }, Graph.execute_query('{current_user{ id }}'))
  end
end
