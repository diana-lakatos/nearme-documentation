# frozen_string_literal: true
module Api
  class Api::GraphController < BaseController
    def create
      query_string = params[:query]
      query_variables = params[:variables] || {}

      result = schema.execute(query_string, variables: query_variables)
      render json: result
    end

    private

    def schema
      Graph::Schema
    end
  end
end
