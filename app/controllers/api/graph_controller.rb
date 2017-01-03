# frozen_string_literal: true
module Api
  class Api::GraphController < BaseController
    def create
      render json: schema.execute(query, variables: variables)
    end

    private

    def schema
      Graph::Schema
    end

    def query
      params[:query]
    end

    def variables
      params[:variables] || {}
    end
  end
end
