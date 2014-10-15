require 'test_helper'

class CustomAttributes::CustomAttribute::FormElementDecorator::SelectTest < ActionView::TestCase

  context 'options' do

    should 'return correct options' do
      expected_hash = {
        :collection => ["These", "Are", "Valid"],
      }
      assert_equal expected_hash, CustomAttributes::CustomAttribute::FormElementDecorator::Select.new(stub("valid_values" => ["These", "Are", "Valid"], "valid_values_translated" => ["These", "Are", "Valid"], name: 'name')).options
    end
  end

end

