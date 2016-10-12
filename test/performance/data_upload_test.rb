# require 'test_helper'
# require 'rails/performance_test_help'
# require 'helpers/gmaps_fake'

# class DataUploadTest < ActionDispatch::PerformanceTest
#   # Refer to the documentation for all available options
#  self.profile_options = { formats: [:call_tree] }

#   CSV_PATH = Rails.root.join('test', 'assets', 'data_importer', 'data_profile.csv')
#   XML_PATH_TMP = Rails.root.join('test', 'assets', 'data_importer', 'data_profile_tmp.xml')
#   XML_PATH = Rails.root.join('test', 'assets', 'data_importer', 'data_profile.xml')

#   setup do
#     GmapsFake.stub_requests
#     stub_image_url("http://www.example.com/image.jpg")
#     stub_image_url("http://www.example.com/photo.jpg")
#     @instance = FactoryGirl.create(:instance)
#     PlatformContext.current = PlatformContext.new(@instance)
#     @location_type = FactoryGirl.create(:location_type, name: 'My Type')
#     @transactable_type = FactoryGirl.create(:transactable_type_csv_template)
#   end
#   test "converting csv to xml" do
#     DataImporter::CsvToXmlConverter.new(DataImporter::CsvFile::TemplateCsvFile.new(CSV_PATH, @transactable_type , {}), XML_PATH_TMP).convert
#   end

#   test "inserting data from xml" do
#     xml_file = DataImporter::XmlFile.new(XML_PATH, @transactable_type)
#     assert_difference 'Transactable.count', 96 do
#       xml_file.parse
#     end
#   end
# end
