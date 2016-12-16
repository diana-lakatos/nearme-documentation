# frozen_string_literal: true
module Api
  class Api::GraphController < BaseController
    if Rails.env.development? # used for autocomplete in IDE
      skip_before_action :verified_api_request?
      skip_before_action :require_authentication
      skip_before_action :require_authorization
    end

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
