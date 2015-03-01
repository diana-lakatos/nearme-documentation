require 'test_helper'

class ValidatorTest < ActiveSupport::TestCase


  context 'valid values' do

    setup do
      @sample_model_type = FactoryGirl.create(:sample_model_type)
      @custom_attribute = FactoryGirl.create(:custom_attribute, target: @sample_model_type, valid_values: ['One', 'Two', 'ąĘĆŹ'], name: 'attr', attribute_type: 'string')
      @sample_model = @sample_model_type.sample_models.build
      @sample_model.apply_custom_attributes
    end

    should 'accept all upper cases' do
      @sample_model.properties.attr = 'ONE'
      assert @sample_model.valid?, @sample_model.errors.full_messages.inspect
    end

    should 'accept all lower cases in validation' do
      @sample_model.properties.attr = 'one'
      assert @sample_model.valid?, @sample_model.errors.full_messages.inspect
    end

    should 'correctly deal with case sensitivity for accents' do
      @sample_model.properties.attr = 'ąęćź'
      assert @sample_model.valid?, @sample_model.errors.full_messages.inspect
    end

    should 'not ignore vlidation completely' do
      @sample_model.properties.attr = 'three'
      refute @sample_model.valid?, @sample_model.errors.full_messages.inspect
    end

    should 'not allow nil' do
      @sample_model.properties.attr = nil
      refute @sample_model.valid?, @sample_model.errors.full_messages.inspect
    end

  end

  context 'validators' do

    setup do
      @sample_model_type = FactoryGirl.create(:sample_model_type)
      @custom_attribute = FactoryGirl.create(:custom_attribute, name: 'name', target: @sample_model_type)
    end

    context 'presence' do

      setup do
        @custom_attribute.update_attributes(validation_rules: { :presence => {} }, attribute_type: 'string')
        @sample_model = FactoryGirl.build(:sample_model, sample_model_type: @sample_model_type)
        @sample_model.apply_custom_attributes
      end

      should 'invoke the right method' do
        ActiveModel::Validations::PresenceValidator.expects(:new).returns(stub(:validate)).twice
        ActiveModel::Validations::NumericalityValidator.expects(:new).never
        ActiveModel::Validations::LengthValidator.expects(:new).never
        ActiveModel::Validations::InclusionValidator.expects(:new).never
        @sample_model.valid?
      end

      should 'be valid if name present' do
        @sample_model.properties.name = 'hello'
        assert @sample_model.valid?, @sample_model.errors.full_messages.inspect
      end

      should 'not be valid if name absent' do
        @sample_model.properties.name = ''
        refute @sample_model.valid?
      end

    end

    context 'inclusion' do

      setup do
        @custom_attribute.update_attributes(validation_rules: { :inclusion => { :in => ["a", "b"]} }, attribute_type: 'string')
        @sample_model = FactoryGirl.build(:sample_model, sample_model_type: @sample_model_type)
        @sample_model.apply_custom_attributes
      end

      should 'know how to validate inclusion' do
        ActiveModel::Validations::InclusionValidator.expects(:new).returns(stub(:validate)).twice
        ActiveModel::Validations::NumericalityValidator.expects(:new).never
        ActiveModel::Validations::PresenceValidator.expects(:new).never
        ActiveModel::Validations::LengthValidator.expects(:new).never
        @sample_model.valid?
      end

      should 'be valid if included in the list' do
        @sample_model.properties.name = 'a'
        assert @sample_model.valid?, @sample_model.errors.full_messages.inspect
      end

      should 'not be valid if not included in the list' do
        @sample_model.properties.name = 'c'
        refute @sample_model.valid?
      end

    end

    context 'numericality' do

      setup do
        @custom_attribute.update_attribute(:validation_rules, { :numericality => {} })
        @sample_model = FactoryGirl.build(:sample_model, sample_model_type: @sample_model_type)
        @sample_model.apply_custom_attributes
      end

      should 'know how to validate numericality' do
        ActiveModel::Validations::NumericalityValidator.expects(:new).returns(stub(:validate)).twice
        ActiveModel::Validations::InclusionValidator.expects(:new).never
        ActiveModel::Validations::PresenceValidator.expects(:new).never
        ActiveModel::Validations::LengthValidator.expects(:new).never
        @sample_model.valid?
      end

      should 'be valid if numeric' do
        @sample_model.properties.name = 123
        assert @sample_model.valid?, @sample_model.errors.full_messages.inspect
      end

    end

    context 'length' do

      setup do
        @custom_attribute.update_attribute(:validation_rules, { :length => { "maximum" => 250 } })
        @sample_model = FactoryGirl.build(:sample_model, sample_model_type: @sample_model_type)
        @sample_model.apply_custom_attributes
      end

      should 'know how to validate length' do
        ActiveModel::Validations::LengthValidator.expects(:new).returns(stub(:validate)).twice
        @sample_model.valid?
      end

      should 'be valid if not above maximum' do
        @sample_model.properties.name = 250
        assert @sample_model.valid?
      end

      should 'not be valid if above maximum' do
        @sample_model.properties.name = 251
        assert @sample_model.valid?
      end

    end
  end

  private

end

