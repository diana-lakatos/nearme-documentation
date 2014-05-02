require 'test_helper'

class TransactableTypeAttributeDecorator::SelectTest < ActionView::TestCase

  context 'options' do

    should 'return correct options' do
      expected_hash = {
        as: :select,
        collection: ["These", "Are", "Valid"],
        input_html: { prompt: "Please pick" }
      }
      assert_equal expected_hash, TransactableTypeAttributeDecorator::Select.new(stub("valid_values" => ["These", "Are", "Valid"], :prompt => 'Please pick')).options
    end
  end

end

