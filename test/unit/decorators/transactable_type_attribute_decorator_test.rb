require 'test_helper'

class TransactableTypeAttributeDecoratorTest < ActionView::TestCase

  context 'default_options' do

    should 'be correct' do
      expected_default_options = {
        :input_html=>{ :hello=>"world" },
        :required=>false
      }
      assert_equal expected_default_options, decorated_attribute({ input_html_options: { :hello => "world" }}).default_options
    end

    should 'know when attribute is required' do
      assert decorated_attribute(validation_rules: { "presence" => {} }).default_options[:required]
    end

    should 'know when attribute is not required' do
      refute decorated_attribute(validation_rules: { "length" => { "maximum" => 200 } }).default_options[:required]
    end
  end

  context' options' do

    context 'input html' do
      should 'deep merge input_html to not lose any settings' do
        expected_input_html = { "a" => 1, "b" => 2, "c" => 1 }
        TransactableTypeAttributeDecorator::Input.stubs(:new).returns(stub(:options => { :input_html => { "a" => 1, "b" => 2 } } ))
        assert_equal expected_input_html, decorated_attribute(input_html_options: { "a" => 2, "c" => 1 }).options[:input_html]
      end
    end

  end

  private

  def decorated_attribute(options = {})
    options.reverse_merge!({ html_tag: :input, name: "attribute" })
    TransactableTypeAttribute.new(options).decorate
  end

end

