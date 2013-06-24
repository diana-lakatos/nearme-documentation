require 'vcr_setup'
require 'test_helper'

class DataImporter::CsvToXmlConverterTest < ActiveSupport::TestCase

  TMP_FILE_PATH = '/tmp/converted.xml'
  ALL_TMP_FILE_PATH = '/tmp/data_all.xml'

  setup do
    ListingType.create(:name => 'Office Space')
    ListingType.create(:name => 'Meeting Room')
    LocationType.create(:name => 'Business')
    Industry.create(:name => 'Commercial Real Estate')
    [ "Administrative Assistant", "Catering", "Coffee/Tea", "Videoconferencing Facilities",
      "Copier", "Fax", "Projector", "Telephone", "Printer", "Scanner", "Television", "Yard Area",
      "Parking", "Lounge Area", "Internet Access", "Wi-Fi", "Whiteboard", ].each { |name| Amenity.create(:name => name) }
  end

  context '#convert' do

    should 'generate the right file' do
      @converter = DataImporter::CsvToXmlConverter.new(DataImporter::CsvFile.new(get_absolute_file_path('data.csv')), TMP_FILE_PATH)
      @converter.convert
      assert FileUtils.compare_file(get_absolute_file_path('data.xml'), TMP_FILE_PATH), "diff #{TMP_FILE_PATH} #{get_absolute_file_path('data.xml')} <- files not equal"
    end

    should 'convert whole dataset' do
      @converter = DataImporter::CsvToXmlConverter.new(DataImporter::CsvFile.new(Rails.root.join('test', 'assets', 'data_importer', 'data_all.csv')), ALL_TMP_FILE_PATH)
      @converter.convert
      assert FileUtils.compare_file(get_absolute_file_path('data_all.xml'), ALL_TMP_FILE_PATH), "diff #{ALL_TMP_FILE_PATH} #{get_absolute_file_path('data_all.xml')} <- files not equal"
    end
  end

  private

  def get_absolute_file_path(name)
    Rails.root.join('test', 'assets', 'data_importer') + name
  end

end
