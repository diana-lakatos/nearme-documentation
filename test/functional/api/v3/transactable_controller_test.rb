# frozen_string_literal: true
require 'test_helper'

class Api::V3::TransactablesControllerTest < ActionController::TestCase
  context '#index' do
    teardown do
      disable_elasticsearch!
    end

    should 'include pricings' do
      @transactable = FactoryGirl.create(:transactable)
      set_authentication_header(@transactable.creator)
      enable_elasticsearch! do
        Transactable.searchable.import
      end

      get :index, format: :json

      assert_equal({ 'hour' => '50.00', 'day' => '50.00' }, JSON.parse(response.body).dig('data', 0, 'attributes', 'pricings'))
    end
  end
end
