# frozen_string_literal: true
class GraphQuery < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance

  validates :name, uniqueness: { scope: [:instance_id] }, presence: true

  class GraphQlQueryValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      validate_syntax(record, attribute, value) && validate_query_against_schema(record, attribute, value)
    end

    private

    def validate_syntax(record, attribute, value)
      GraphQL.parse(value)
      true
    rescue GraphQL::ParseError => e
      record.errors[attribute] << "Query parse error: #{e.message}"
      false
    end

    def validate_query_against_schema(record, attribute, value)
      validator = GraphQL::StaticValidation::Validator.new(schema: Graph::Schema)
      query = GraphQL::Query.new(Graph::Schema, value)
      query_errors = validator.validate(query)[:errors]
      return if query_errors.empty?

      record.errors[attribute] << query_errors.map(&:message).join(', ')
    end
  end

  validates :query_string, presence: true, graph_ql_query: true

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
end
