# frozen_string_literal: true
require 'test_helper'

class LongtailApiEndpointTest < ActiveSupport::TestCase
  setup do
    @endpoint = LongtailApi::Endpoint.new(host: 'http://example.com', token: 'abc')
  end

  context 'call' do
    should 'use host and token' do
      stub_endpoint_response
      assert_equal 'response', @endpoint.call('/my/path')
    end

    should 'accept relative path' do
      stub_endpoint_response
      assert_equal 'response', @endpoint.call('my/path')
    end

    should 'not duplicate host if included in path' do
      stub_endpoint_response
      assert_equal 'response', @endpoint.call('http://example.com/my/path')
    end
  end

  protected

  def stub_endpoint_response
    stub_request(:get, 'http://example.com/my/path')
      .with(headers: { 'Authorization' => 'Bearer abc' })
      .to_return(status: 200, body: 'response')
  end
end
