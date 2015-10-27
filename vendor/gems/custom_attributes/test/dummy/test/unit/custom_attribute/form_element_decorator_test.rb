require 'test_helper'

class CustomAttributes::CustomAttribute::FormElementDecoratorTest < ActionView::TestCase

  context 'default_options' do

    should 'be correct' do
      expected_default_options = {
        :input_html=>{"hello"=>"world"},
        :label=>"Attribute",
        :hint=>nil,
        :placeholder=>nil,
        :include_blank=>nil,
        :required=>false
      }
      assert_equal expected_default_options, form_element({ input_html_options: { "hello" => "world" }}).default_options
    end

    should 'know when attribute is required' do
      assert form_element(validation_rules: { "presence" => {} }).default_options[:required]
    end

    should 'know when attribute is not required' do
      refute form_element(validation_rules: { "length" => { "maximum" => 200 } }).default_options[:required]
    end
  end

  context' options' do

    context 'input html' do
      should 'deep merge input_html to not lose any settings' do
        expected_input_html = { "a" => 1, "b" => 2, "c" => 1 }
        CustomAttributes::CustomAttribute::FormElementDecorator::Input.stubs(:new).returns(stub(:options => { :input_html => { "a" => 1, "b" => 2 } } ))
        assert_equal expected_input_html, form_element(input_html_options: { "a" => 2, "c" => 1 }).options[:input_html]
      end
    end

  end

  private

  def form_element(options = {})
    options.reverse_merge!({ html_tag: :input, name: "attribute", target: FactoryGirl.build(:sample_model_type, name: 'my name')})
    CustomAttributes::CustomAttribute::FormElementDecorator.new(CustomAttributes::CustomAttribute.new(options))
  end

end

