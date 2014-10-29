require 'test_helper'

class CsvTemplateGeneratorTest < ActiveSupport::TestCase

  def setup
    @instance = FactoryGirl.create(:instance)
    PlatformContext.current = PlatformContext.new(@instance)
    @transactable_type = FactoryGirl.create(:transactable_type)
    CustomAttributes::CustomAttribute.destroy_all
    @public_attribute = FactoryGirl.create(:custom_attribute, target: @transactable_type, name: 'public_attribute', label: 'My Public Attribute', public: true, internal: false)
    @internal_public_attribute = FactoryGirl.create(:custom_attribute, target: @transactable_type, name: 'public_internal_attribute', label: nil, internal: true, public: true)
    @internal_private_attribute = FactoryGirl.create(:custom_attribute, target: @transactable_type, name: 'private_internal_attribute', label: 'My Private Internal Attribute', internal: true, public: false)
  end

  context 'template for MPO' do
    should 'contain only public attributes' do
      result_csv = DataImporter::CsvTemplateGenerator.new(@transactable_type).generate_template
      assert result_csv.include?('User Email'), "User email not included in: #{result_csv}"
      assert result_csv.include?('Company Name'), "Company Name not included in: #{result_csv}"
      assert result_csv.include?('Location Email'), "Location Email not included in: #{result_csv}"
      assert result_csv.include?('My Public Attribute'), "Public non internal attribute not included in: #{result_csv}"
      assert result_csv.include?('Public internal attribute'), "Public internal attribute not included in: #{result_csv}"
      refute result_csv.include?('My Private Internal Attribute'), "Private internal attribute included in: #{result_csv}"
    end
  end

  context 'template for host' do
    should 'do not contain fields for company and user' do
      result_csv = DataImporter::Host::CsvTemplateGenerator.new(@transactable_type).generate_template
      refute result_csv.include?('User Email'), "User email included in: #{result_csv}"
      refute result_csv.include?('Company Name'), "Company Name included in: #{result_csv}"
      assert result_csv.include?('Location Email'), "Location Email not included in: #{result_csv}"
    end
  end

end
