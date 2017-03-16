# frozen_string_literal: true
require 'test_helper'

class FormObjectFactoryTest < ActiveSupport::TestCase
  should 'return user with id' do
    u = FactoryGirl.create(:user)
  end
end
