require 'test_helper'
require 'helpers/gmaps_fake'

class DataImporter::Tracker::SummaryTest < ActiveSupport::TestCase
  setup do
    GmapsFake.stub_requests
    stub_image_url('http://www.example.com/image.jpg')
    stub_image_url('http://www.example.com/photo.jpg')
    @instance = FactoryGirl.create(:instance)
    PlatformContext.current = PlatformContext.new(@instance)
    @location_type = FactoryGirl.create(:location_type, name: 'My Type')
  end

  should 'get correct summaries' do
    @xml_file = FactoryGirl.create(:xml_template_file)
    @summary_tracker = DataImporter::Tracker::Summary.new
    @xml_file.trackers << @summary_tracker
    @xml_file.parse
    assert_equal({ 'user' => 2, 'company' => 2, 'location' => 3, 'transactable' => 4, 'photo' => 4 }, @summary_tracker.new_entities)
    assert_equal({ 'user' => 0, 'company' => 0, 'location' => 0, 'transactable' => 0, 'photo' => 0 }, @summary_tracker.updated_entities)
    @xml_file = FactoryGirl.create(:xml_template_file)
    @summary_tracker = DataImporter::Tracker::Summary.new
    @xml_file.trackers << @summary_tracker
    @xml_file.parse
    assert_equal({ 'user' => 0, 'company' => 0, 'location' => 0, 'transactable' => 0, 'photo' => 0 }, @summary_tracker.new_entities)
    assert_equal({ 'user' => 2, 'company' => 2, 'location' => 3, 'transactable' => 4, 'photo' => 0 }, @summary_tracker.updated_entities)
  end
end
