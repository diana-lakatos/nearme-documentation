require 'test_helper'

class Utils::FormComponentsCreatorTest < ActiveSupport::TestCase

  setup do
    @transactable_type = FactoryGirl.create(:transactable_type)
  end

  context "#create!" do

    should 'create 4 sections by default' do
      @form_component_creator = Utils::FormComponentsCreator.new(@transactable_type)
      assert_difference 'FormComponent.count', 6 do
        @form_component_creator.create!
      end
    end

    should 'create 5 sections if user info is enabled' do
      @transactable_type.instance
      @form_component_creator = Utils::FormComponentsCreator.new(@transactable_type)
      assert_difference 'FormComponent.count', 6 do
        @form_component_creator.create!
      end
    end
  end
end
