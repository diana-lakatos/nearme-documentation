require 'test_helper'

class DataImporter::CsvTemplateGeneratorTest < ActiveSupport::TestCase

  setup do
    @instance = FactoryGirl.create(:instance)
    PlatformContext.current = PlatformContext.new(@instance)
  end

  context 'transactables' do

    setup do
      @transactable_type = FactoryGirl.create(:transactable_type)
      CustomAttributes::CustomAttribute.destroy_all
      @public_attribute = FactoryGirl.create(:custom_attribute, target: @transactable_type, name: 'public_attribute', label: 'My Public Attribute', public: true)
      @private_attribute = FactoryGirl.create(:custom_attribute, target: @transactable_type, name: 'private_attribute', label: 'My Private Attribute', public: false)
    end

    context 'template for MPO' do

      should 'contain only public attributes' do
        result_csv = DataImporter::CsvTemplateGenerator.new(@transactable_type, true).generate
        assert result_csv.include?('User Email'), "User email not included in: #{result_csv}"
        assert result_csv.include?('Company Name'), "Company Name not included in: #{result_csv}"
        assert result_csv.include?('Location Email'), "Location Email not included in: #{result_csv}"
        assert result_csv.include?('My Public Attribute'), "Public attribute not included in: #{result_csv}"
        refute result_csv.include?('My Private Attribute'), "Private attribute included in: #{result_csv}"
      end
    end

    context 'template for host' do
      should 'do not contain fields for company and user' do
        result_csv = DataImporter::Host::CsvTemplateGenerator.new(@transactable_type).generate
        refute result_csv.include?('User Email'), "User email included in: #{result_csv}"
        refute result_csv.include?('Company Name'), "Company Name included in: #{result_csv}"
        assert result_csv.include?('Location Email'), "Location Email not included in: #{result_csv}"
        assert result_csv.include?('My Public Attribute'), "Public attribute not included in: #{result_csv}"
        refute result_csv.include?('My Private Attribute'), "Private attribute included in: #{result_csv}"
      end

      should 'allow to include custom fields in template' do
        @transactable_type.update_attribute(:custom_csv_fields, [ {'transactable' => 'public_attribute'}, {'location' => 'email'} ])
        result_csv = DataImporter::Host::CsvTemplateGenerator.new(@transactable_type).generate
        assert_equal "My Public Attribute,Location Email\n", result_csv
      end
    end
  end

end
