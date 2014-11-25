require 'test_helper'

class ValidatorTest < ActiveSupport::TestCase

  should 'know how to validate presence' do
    ActiveModel::Validations::PresenceValidator.expects(:new).returns(stub(:validate))
    CustomAttributes::Validator.new({:attributes => {}}).validate(record(['name', 'integer', { :presence => {} }, nil]))
  end

  should 'know how to validate inclusion' do
    ActiveModel::Validations::InclusionValidator.expects(:new).returns(stub(:validate))
    CustomAttributes::Validator.new({:attributes => {}}).validate(record(['name', 'integer', { :inclusion => { :in => ["a", "b"]} }, nil]))
  end

  should 'know how to validate numericality' do
    ActiveModel::Validations::NumericalityValidator.expects(:new).returns(stub(:validate))
    CustomAttributes::Validator.new({:attributes => {}}).validate(record(['name', 'integer', { :numericality => {} }, nil]))

  end

  should 'know how to validate length' do
    ActiveModel::Validations::LengthValidator.expects(:new).returns(stub(:validate))
    CustomAttributes::Validator.new({:attributes => {}}).validate(record(['name', 'integer', { :length => { "maximum" => 250 } }, nil]))
  end

  private

  def record(array)
    stub(transactable_type_id: 1, custom_attributes: [attributes(*array)])
  end

  def attributes(name, type, rules, values)
    [name, type, nil, nil, rules, values]
  end

end
