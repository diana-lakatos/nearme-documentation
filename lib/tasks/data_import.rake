namespace :import do
  desc "import data from xml file"
  task :xml => :environment do
    @xml_file = DataImporter::XmlFile.new(Rails.root.join('test', 'assets', 'data_importer', 'data.xml'))
    @xml_file.parse
  end

  desc "import data from csv file"
  task :csv => :environment do
    start = Time.now
    @converter = DataImporter::CsvToXmlConverter.new(DataImporter::CsvFile.new(Rails.root.join('test', 'assets', 'data_importer', 'data_all.csv')), '/tmp/data_all.xml')
    @converter.convert
    @xml_file = DataImporter::XmlFile.new('/tmp/data_all.xml')
    @xml_file.parse
    execution_time_in_seconds = Time.now - start
    printf("**took %.1f seconds\n", execution_time_in_seconds)
  end
end
