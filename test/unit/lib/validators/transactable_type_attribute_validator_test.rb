require 'test_helper'

class TransactableTypeAttributeValidatorTest < ActiveSupport::TestCase

  should 'know how to validate presence' do
    record = stub(:transactable_type_attributes => [stub(:validation_rules => { :presence => {} }, :name => 'name', valid_values: nil)])
    ActiveModel::Validations::PresenceValidator.expects(:new).returns(stub(:validate))
    TransactableTypeAttributeValidator.new({:attributes => {}}).validate(record)

  end

  should 'know how to validate inclusion' do
    record = stub(:transactable_type_attributes => [ stub(:validation_rules => { :inclusion => { :in => ["a", "b"]} }, :name => 'name', valid_values: nil)])
    ActiveModel::Validations::InclusionValidator.expects(:new).returns(stub(:validate))
    TransactableTypeAttributeValidator.new({:attributes => {}}).validate(record)
  end

  should 'know how to validate numericality' do
    record = stub(:transactable_type_attributes => [stub(:validation_rules => { :numericality => {} }, :name => 'name', valid_values: nil)])
    ActiveModel::Validations::NumericalityValidator.expects(:new).returns(stub(:validate))
    TransactableTypeAttributeValidator.new({:attributes => {}}).validate(record)

  end

  should 'know how to validate length' do
    record = stub(:transactable_type_attributes => [stub(:validation_rules => { :length => { "maximum" => 250 } }, :name => 'name', valid_values: nil)])
    ActiveModel::Validations::LengthValidator.expects(:new).returns(stub(:validate))
    TransactableTypeAttributeValidator.new({:attributes => {}}).validate(record)
  end

  should 'automatically add validation for valid values' do
    record = stub(:transactable_type_attributes => [ stub(:validation_rules => nil, :name => 'name', valid_values: ["A", "B"])])
    ActiveModel::Validations::InclusionValidator.expects(:new).with({ attributes: "name", in: ["A", "B"] }).returns(stub(:validate))
    TransactableTypeAttributeValidator.new({:attributes => {}}).validate(record)
  end


end
