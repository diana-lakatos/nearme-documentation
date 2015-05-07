class DataUploadHostConvertJob < Job

  include Job::LongRunning

  def after_initialize(data_upload_id)
    @data_upload_id = data_upload_id
  end

  def perform
    @data_upload = DataUpload.find(@data_upload_id)
    @data_upload.process!
    begin
      csv_file = DataImporter::Host::CsvFile::TemplateCsvFile.new(@data_upload)
      xml_path = "#{Dir.tmpdir}/#{@data_upload.importable_id}-#{Time.zone.now.to_i}.xml"
      DataImporter::CsvToXmlConverter.new(csv_file, xml_path, @data_upload.importable).convert
      @data_upload.xml_file = File.open(xml_path)

      @data_upload.save!
      @data_upload.queue
    rescue
      @data_upload.encountered_error = "#{$!.inspect}\n\n#{$@[0..5]}"
      @data_upload.fail
    ensure
      @data_upload.save!
      DataUploadImportJob.perform(@data_upload.id)
    end
  end

end

