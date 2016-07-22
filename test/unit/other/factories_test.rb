require 'test_helper'

class FactoriesTest < ActiveSupport::TestCase

  FactoryGirl.factories.each do |factory|
    # next if factory.name.in?(%i(payment_with_refund user_with_addresses)) #bug in spree: not mentioned class_name

    context "Factory: #{factory.name}" do
      should "return valid resource" do
        stub_us_geolocation
        resource = FactoryGirl.build(factory.name)
        assert resource.valid?, "Resource (#{factory.name}) invalid because of: #{resource.errors.full_messages.join(", ")}" if resource.respond_to?(:valid)
        puts(" - #{factory.name}")
      end
    end
  end
end
