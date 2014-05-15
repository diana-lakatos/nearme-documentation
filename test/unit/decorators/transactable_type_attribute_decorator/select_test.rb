require 'test_helper'

class TransactableTypeAttributeDecorator::SelectTest < ActionView::TestCase

  context 'options' do

    should 'return correct options' do
      expected_hash = {
        :collection => ["These", "Are", "Valid"],
        :prompt=>"translation missing: en.simple_form.prompts.transactable.name"
      }
      assert_equal expected_hash, TransactableTypeAttributeDecorator::Select.new(stub("valid_values" => ["These", "Are", "Valid"], "valid_values_translated" => ["These", "Are", "Valid"], :name => 'name')).options
    end
  end

end

