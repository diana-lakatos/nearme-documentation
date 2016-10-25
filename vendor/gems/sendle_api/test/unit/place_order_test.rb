require 'test_helper'
require './lib/sendle_api'

describe SendleApi::Client do
  include SendleClientSupport
  include Factories

  describe 'when placing new order', :vcr do
    before do
    end

    it 'reports errors when valid params' do
      response = client.place_order order_params

      %w(messages error error_description).each do |required|
        response.body.wont_include required
      end

      response.success?.must_equal true

      %w(address contact).each do |required|
        response.body.fetch('sender').must_include required
      end
    end

    it 'reports errors when provided invalid params' do
      response = client.place_order sender: {}
      response.success?.must_equal false

      %w(messages error error_description).each do |required|
        response.body.must_include required
      end

      %w(description receiver sender).each do |required|
        response.body.fetch('messages').must_include required
      end
    end
  end
end
