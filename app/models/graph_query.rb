# frozen_string_literal: true
class GraphQuery < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance

  validates :name, uniqueness: { scope: [:instance_id] }
  validate :parse_query

  def generate_tag_line
    "{% query_graph '#{name}', result_name: g #{tag_params_clause} %}"
  end

  private

  def variables
    GraphQL.parse(query_string).definitions.map(&:variables).flatten.map(&:name)
  end

  def tag_params_clause
    clause = variables.map { |v| "#{v}: #{v}" }.join(', ')
    clause.present? ? ", #{clause}" : ''
  end

  def parse_query
    GraphQL.parse(query_string)
  rescue GraphQL::ParseError => e
    errors[:query_string] << "Query parse error: #{e.message}"
  end
end
