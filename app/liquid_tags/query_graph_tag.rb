# frozen_string_literal: true
# Usage example:
# ```
#  {% query_graph 'users_query', result_name: g, current_user: current_user %}
# ```
#
# Used to execute defined graph query.
class QueryGraphTag < Liquid::Tag
  include AttributesParserHelper

  SYNTAX = /(#{Liquid::VariableSignature}+)\s*/o
  DEFAULT_RESULT_NAME = 'g'

  def initialize(tag_name, markup, tokens)
    raise SyntaxError, 'Invalid syntax for Input tag - must pass field name' if markup !~ SYNTAX

    super
    @query_name = Regexp.last_match(1)
    attributes = create_initial_hash_from_liquid_tag_markup(markup)
    @result_name = attributes.delete('result_name') || DEFAULT_RESULT_NAME
    @params = attributes
  end

  def render(context)
    assign_variables(context, execute_query(context))
    ''
  end

  private

  def execute_query(context)
    response = ::Graph::Schema.execute(
      query_string,
      variables: variables(context),
      context: {
        current_user: current_user(context),
        liquid_context: context
      }
    )
    response.key?('data') ? response.fetch('data') : throw(ArgumentError.new(response.pretty_inspect))
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

  def current_user(context)
    context['current_user']
  end
end
