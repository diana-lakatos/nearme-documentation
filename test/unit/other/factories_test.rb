require 'test_helper'

class FactoriesTest < ActiveSupport::TestCase

  SPREE_EXCLUDED_FACTORIES = ['admin_user', 'user_with_addreses']

  FactoryGirl.factories.each do |factory|
    next if factory.class_name.to_s.gsub(/::.*/, '') == 'Spree' ||
      SPREE_EXCLUDED_FACTORIES.include?(factory.name.to_s)

    context "Factory: #{factory.name}" do
      should "return valid resource" do
        resource = FactoryGirl.build(factory.name)
        assert resource.valid?, "Resource (#{factory.name}) invalid because of: #{resource.errors.full_messages.join(", ")}"
      end
    end
  end

end
