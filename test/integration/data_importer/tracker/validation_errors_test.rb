require 'helpers/gmaps_fake'
require 'test_helper'

class DataImporter::Tracker::ValidationErrorsTest < ActiveSupport::TestCase
  setup do
    GmapsFake.stub_requests
    stub_image_url('http://www.example.com/image.jpg')
    stub_image_url('http://www.example.com/photo.jpg')
    @instance = FactoryGirl.create(:instance)
    PlatformContext.current = PlatformContext.new(@instance)
    @location_type = FactoryGirl.create(:location_type, name: 'My Type')
    @validation_errors_tracker = DataImporter::Tracker::ValidationErrors.new
  end

  should 'persist location if location invalid' do
    @xml_file = FactoryGirl.create(:host_xml_template_file_invalid_transactable)
    @xml_file.trackers << @validation_errors_tracker
    assert_no_difference 'Location.count' do
      assert_no_difference 'Transactable.count' do
        @xml_file.parse
        assert @validation_errors_tracker.to_s.strip.include?("My attribute can't be blank")
      end
    end
  end

  should 'not log anything if all entities are valid' do
    @xml_file = FactoryGirl.create(:xml_template_file)
    @xml_file.trackers << @validation_errors_tracker
    @xml_file.parse
    assert_equal '', @validation_errors_tracker.to_s.strip
  end

  should 'log company errors' do
    @xml_file = FactoryGirl.create(:xml_template_file_invalid_company)
    @xml_file.trackers << @validation_errors_tracker
    @xml_file.parse
    assert_equal "Validation error for Company 1: Name can't be blank. Ignoring all children.", @validation_errors_tracker.to_s.strip
  end

  should 'log that there are no valid users for company' do
    @xml_file = FactoryGirl.create(:xml_template_file_no_valid_users)
    @xml_file.trackers << @validation_errors_tracker
    assert_no_difference 'Company.count' do
      @xml_file.parse
    end
    assert_equal "Validation error for User user2@example.com: Name can't be blank and First name can't be blank. Ignoring all children.\nCompany 1 has no valid user, skipping", @validation_errors_tracker.to_s.strip
  end

  should 'log location address errors' do
    @xml_file = FactoryGirl.create(:xml_template_file_invalid_location_address)
    @xml_file.trackers << @validation_errors_tracker
    @xml_file.parse
    assert_equal "Validation error for Location 1: Location address address can't be blank, Location address latitude can't be blank, and Location address longitude can't be blank. Ignoring all children.", @validation_errors_tracker.to_s.strip
  end

  should 'log transactable errors' do
    @xml_file = FactoryGirl.create(:xml_template_file_invalid_transactable)
    @xml_file.trackers << @validation_errors_tracker
    @xml_file.parse

    assert_contains 'Validation error for Transactable 1: ', @validation_errors_tracker.to_s
    assert @validation_errors_tracker.to_s.include?("My attribute can't be blank")
    assert @validation_errors_tracker.to_s.include?('Validation error for Location 1: ')
  end
end
