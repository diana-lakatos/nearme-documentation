# frozen_string_literal: true
require 'graph/schema'

# Usage example:
# ```
#  {% execute_query users_query, result_name: g, current_user: current_user %}
# ```
#
# Used to execute defined graph query.
class ExecuteGraphqlQueryTag < Liquid::Tag
  include AttributesParserHelper

  SYNTAX = /(#{Liquid::VariableSignature}+)\s*/o
  DEFAULT_RESULT_NAME = 'g'

  def initialize(tag_name, markup, tokens)
    raise SyntaxError, 'Invalid syntax for Input tag - must pass field name' if markup !~ SYNTAX
    @query_name = Regexp.last_match(1)
    # raise SyntaxError, "No graphql query found for name: #{@query_name}" unless query_exists? #TODO: ensure we have valid query

    super
    attributes = create_initial_hash_from_liquid_tag_markup(markup)
    @result_name = attributes.delete('result_name') || DEFAULT_RESULT_NAME
    @params = attributes
  end

  def render(context)
    result = execute_query(context)
    assign_variables(context, result)
    log(result)
    ''
  end

  private

  def execute_query(context)
    ::Graph.execute_query(
      query_string,
      variables: variables(context),
      context: context
    )
  end

  def query_string
    Graph::QueryResolver.find_query(@query_name)
  end

  def assign_variables(context, variables)
    context.scopes.last[@result_name] = variables
  end

  def variables(context)
    Hash[@params.map { |key, variable_name| [key, context[variable_name]] }]
  end

  def log(result)
    return unless Rails.env.debug_graphql?
    "<script>console.dir(#{result.to_json})</script>"
  end

  def query_exists?
    GraphQuery.exists_by_name?(@query_name)
  end
end
