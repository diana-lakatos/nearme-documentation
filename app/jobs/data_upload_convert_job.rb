class DataUploadConvertJob < Job

  def after_initialize(data_upload_id)
    @data_upload_id = data_upload_id
  end

  def perform
    @data_upload = DataUpload.find(@data_upload_id)
    @data_upload.process!
    csv_file = DataImporter::CsvFile::TemplateCsvFile.new(@data_upload.csv_file.proper_file_path, @data_upload.transactable_type, @data_upload.options)
    xml_path = "#{Dir.tmpdir}/#{@data_upload.transactable_type_id}-#{Time.zone.now.to_i}.xml"
    DataImporter::CsvToXmlConverter.new(csv_file, xml_path).convert
    @data_upload.xml_file = File.open(xml_path)
    @data_upload.save!
    @data_upload.queue!
    DataUploadImportJob.perform(@data_upload.id)
  end

end

