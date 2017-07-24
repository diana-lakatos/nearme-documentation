# frozen_string_literal: true
require 'test_helper'

class SubmitForm::IndexInElasticTest < ActiveSupport::TestCase
  should 'work with object not releated with elastic' do
    category = FactoryGirl.create(:category)

    objects = SubmitForm::IndexInElastic::ElasticReleatedObjects.new(category).to_a

    assert_equal [], objects
  end
end
