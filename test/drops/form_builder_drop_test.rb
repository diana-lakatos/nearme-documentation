require 'test_helper'

class FormBuilderDropTest < ActionView::TestCase
  setup do
    @form_class = LocationForm.decorate(
      description: { validation: { presence: true } },
      email: { validation: { presence: true } }
    )
  end

  test 'validations for form' do
    assert_equal(
      { 'description' => ['presence'], 'email' => ['presence'] },
      SimpleForm::FormBuilderDrop::FormValidations.new(@form_class).to_h
    )
  end

  test 'required_fields for form' do
    assert_equal %w(description email), SimpleForm::FormBuilderDrop::FormValidations.new(@form_class).required_fields
  end
end
