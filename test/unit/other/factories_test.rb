require 'test_helper'

class FactoriesTest < ActiveSupport::TestCase

  FactoryGirl.factories.each do |factory|
    context "Factory: #{factory.name}" do
      should "return valid resource" do
        resource = FactoryGirl.build(factory.name)
        assert resource.valid?, "Resource (#{factory.name}) invalid because of: #{resource.errors.full_messages.join(", ")}"
      end
    end
  end

end
