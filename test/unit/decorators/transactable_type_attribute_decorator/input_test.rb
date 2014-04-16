require 'test_helper'

class TransactableTypeAttributeDecorator::InputTest < ActionView::TestCase

  context 'limit' do

    should 'know if attribute is not limited at all' do
      assert_nil TransactableTypeAttributeDecorator::Input.new(stub("validation_rules" => {})).limit
    end

    should 'know if attribute is limited but with minimal length' do
      assert_nil TransactableTypeAttributeDecorator::Input.new(stub("validation_rules" => { "length" => { "minimum" => 50 } })).limit
    end

    should 'know when attribute is limited as string' do
      input = TransactableTypeAttributeDecorator::Input.new(stub("validation_rules" => { "length" => { "maximum" => 50 } }))
      assert_equal 50, input.limit
      assert_equal :limited_string, input.custom_as[:as]
    end

    should 'know when attribute is limited as text' do
      input = TransactableTypeAttributeDecorator::Input.new(stub("validation_rules" => { "length" => { "maximum" => 51 } }))
      assert_equal 51, input.limit
      assert_equal :limited_text, input.custom_as[:as]
    end

  end

  context 'options with custom as' do

    should 'return correct custom_as hash with options' do
      expected_hash = {
        placeholder: 'hello',
        as: :limited_string,
        limit: 50,
        input_html: { :maxlength => 50 }
      }
      assert_equal expected_hash, TransactableTypeAttributeDecorator::Input.new(stub("validation_rules" => { "length" => { "maximum" => 50 } }, :placeholder => 'hello')).options
    end
  end

end

