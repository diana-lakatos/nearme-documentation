require 'test_helper'

class DataImporter::CsvToXmlConverterTest < ActiveSupport::TestCase
  setup do
    TransactableType.destroy_all
  end
  context 'mpo' do
    context '#convert' do
      setup do
        @csv_file = FactoryGirl.create(:csv_template_file)
        @xml_file = FactoryGirl.create(:xml_template_file)
      end

      should 'transform csv template correctly' do
        @xml_path = '/tmp/template.xml'
        @converter = DataImporter::CsvToXmlConverter.new(@csv_file, @xml_path, nil)
        @converter.convert
        assert FileUtils.compare_file(@xml_path, @xml_file.path), "diff #{@xml_path} #{@xml_file.path} <- files not equal"
      end
    end
  end

  context 'host' do
    setup do
      @csv_file = FactoryGirl.create(:host_csv_template_file)
      @xml_file = FactoryGirl.create(:host_xml_template_file)
    end

    should 'transform csv template correctly' do
      @xml_path = '/tmp/template.xml'
      @converter = DataImporter::CsvToXmlConverter.new(@csv_file, @xml_path, nil)
      @converter.convert
      assert FileUtils.compare_file(@xml_path, @xml_file.path), "diff #{@xml_path} #{@xml_file.path} <- files not equal"
    end
  end
end
