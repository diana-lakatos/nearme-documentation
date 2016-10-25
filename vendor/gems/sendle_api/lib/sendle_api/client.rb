require 'English'
require 'json'
require 'faraday'
require 'faraday_middleware'

require 'sendle_api/response'
require 'sendle_api/html_client'

module SendleApi
  class Client
    def initialize(sendle_api_key: nil, sendle_id: nil)
      @api_key = sendle_api_key || ENV['SENDLE_API_KEY']
      @sendle_id = sendle_id || ENV['SENDLE_ID']
    end

    def ping
      api.get 'ping'
    end

    def view_order(order_id:)
      api.get "orders/#{order_id}"
    end

    def get_quote(params)
      api.get 'quote', params
    end

    def place_order(params)
      api.post 'orders', params
    end

    def cancel_order(order_id:)
      api.delete "orders/#{order_id}"
    end

    def track_parcel(sendle_reference:)
      api.get "tracking/#{sendle_reference}"
    end

    private

    SANDBOX_URL = 'https://sandbox.sendle.com/api/'.freeze

    def api
      SendleApi::HttpClient.new user: @sendle_id, password: @api_key, url: SANDBOX_URL
    end
  end
end
