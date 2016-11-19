# frozen_string_literal: true
require 'test_helper'
require './lib/sendle_api'
require './lib/sendle_api/validations'

include SendleApi
describe Validations do
  include Factories

  describe 'order' do
    it 'raises error on invalid sender' do
      lambda do
        Validations.sender address_params: address_params, instructions: 'some instructions'
      end.must_raise ArgumentError

      lambda do
        Validations.sender contact: contact_params, instructions: 'some instructions'
      end.must_raise ArgumentError

      Validations.address(**address_params).must_equal address_params
      Validations.contact(**contact_params).must_equal contact_params

      Validations.sender(
        contact: contact_params,
        address: address_params,
        instructions: 'some instructions'
      ).must_equal sender_params(instructions: 'some instructions')
    end
  end
end
