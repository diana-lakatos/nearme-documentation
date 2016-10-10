class DataUploadConvertJob < Job
  include Job::LongRunning

  def after_initialize(data_upload_id)
    @data_upload_id = data_upload_id
  end

  def perform
    @data_upload = DataUpload.find(@data_upload_id)

    @data_upload.process! unless @data_upload.processing?
    xml_path = "#{Dir.tmpdir}/#{@data_upload.importable_id}-#{Time.zone.now.to_i}.xml"
    DataImporter::CsvToXmlConverter.new(csv_file, xml_path, @data_upload.importable).convert
    @data_upload.xml_file = File.open(xml_path)
    @data_upload.queue!
    DataUploadImportJob.perform(@data_upload.id)
  rescue
    @data_upload.encountered_error = "#{$ERROR_INFO.inspect}\n\n#{$ERROR_POSITION[0..5]}"
    @data_upload.failure!
  end

  protected

  def csv_file
    @csv_file ||= DataImporter::CsvFile::TemplateCsvFile.new(@data_upload, 'Company External Id')
  end
end
