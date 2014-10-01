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

  should 'contain only public attributes' do
    result_csv = DataImporter::CsvTemplateGenerator.new(@transactable_type).generate_template
    assert result_csv.include?('My Public Attribute'), "Public non internal attribute not included in: #{result_csv}"
    assert result_csv.include?('Public internal attribute'), "Public internal attribute not included in: #{result_csv}"
  end

end
