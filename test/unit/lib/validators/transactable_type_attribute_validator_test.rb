require 'test_helper'

class TransactableTypeAttributeValidatorTest < ActiveSupport::TestCase

  should 'know how to validate presence' do
    TransactableTypeAttributeValidator.any_instance.stubs(:transactable_type_attributes).returns([['name', { :presence => {} }, nil]])
    ActiveModel::Validations::PresenceValidator.expects(:new).returns(stub(:validate))
    TransactableTypeAttributeValidator.new({:attributes => {}}).validate(stub(transactable_type_id: 1))
  end

  should 'know how to validate inclusion' do
    TransactableTypeAttributeValidator.any_instance.stubs(:transactable_type_attributes).returns([['name', { :inclusion => { :in => ["a", "b"]} }, nil]])
    ActiveModel::Validations::InclusionValidator.expects(:new).returns(stub(:validate))
    TransactableTypeAttributeValidator.new({:attributes => {}}).validate(stub(transactable_type_id: 1))
  end

  should 'know how to validate numericality' do
    TransactableTypeAttributeValidator.any_instance.stubs(:transactable_type_attributes).returns([['name', { :numericality => {} }, nil]])
    ActiveModel::Validations::NumericalityValidator.expects(:new).returns(stub(:validate))
    TransactableTypeAttributeValidator.new({:attributes => {}}).validate(stub(transactable_type_id: 1))

  end

  should 'know how to validate length' do
    TransactableTypeAttributeValidator.any_instance.stubs(:transactable_type_attributes).returns([['name', { :length => { "maximum" => 250 } }, nil]])
    ActiveModel::Validations::LengthValidator.expects(:new).returns(stub(:validate))
    TransactableTypeAttributeValidator.new({:attributes => {}}).validate(stub(transactable_type_id: 1))
  end

  should 'automatically add validation for valid values' do
    TransactableTypeAttributeValidator.any_instance.stubs(:transactable_type_attributes).returns([['name', nil, ["A", "B"]]])
    ActiveModel::Validations::InclusionValidator.expects(:new).with({ attributes: "name", in: ["A", "B"] }).returns(stub(:validate))
    TransactableTypeAttributeValidator.new({:attributes => {}}).validate(stub(transactable_type_id: 1))
  end


end
