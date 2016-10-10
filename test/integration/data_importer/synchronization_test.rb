require 'test_helper'
require 'helpers/gmaps_fake'

class DataImporter::XmlFileTest < ActiveSupport::TestCase
  setup do
    GmapsFake.stub_requests
    stub_image_url('http://www.example.com/image.jpg')
    stub_image_url('http://www.example.com/photo.jpg')
    @instance = FactoryGirl.create(:instance)
    PlatformContext.current = PlatformContext.new(@instance)
    @location_type = FactoryGirl.create(:location_type, name: 'My Type')
  end

  context 'with extra listing' do
    setup do
      @xml_file = FactoryGirl.create(:xml_template_file)
      @xml_file.parse
      @company = @instance.companies.find_by_external_id('1')
      @transactable_to_be_deleted = FactoryGirl.create(:transactable, properties: { my_attribute: 'name' }, location: @company.locations.first)
    end

    should 'remove listings which do not exist in csv if sync is on for the company' do
      assert_difference 'Transactable.count', -1 do
        @xml_file = FactoryGirl.create(:xml_template_file_sync_mode)
        @xml_file.parse
      end
      assert @transactable_to_be_deleted.reload.deleted?
    end

    should 'leave listings alone which do not exist in csv if sync is off' do
      assert_no_difference 'Transactable.count' do
        @xml_file.parse
      end
      refute @transactable_to_be_deleted.reload.deleted?
    end
  end

  should 'do not remove invalid listing' do
    @xml_file = FactoryGirl.create(:xml_template_file)
    @xml_file.parse

    assert_difference 'Transactable.count', -1 do
      @xml_file = FactoryGirl.create(:xml_template_file_sync_mode_invalid_transactable)
      @xml_file.parse
    end
    assert_not_nil Transactable.find_by_external_id('1')
    assert_nil Transactable.find_by_external_id('2')
  end
end
