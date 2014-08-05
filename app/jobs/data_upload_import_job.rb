class DataUploadImportJob < Job

  def after_initialize(data_upload_id)
    @data_upload_id = data_upload_id
  end

  def perform
    @data_upload = DataUpload.find(@data_upload_id)
    @xml_file = DataImporter::XmlFile.new(@data_upload.xml_file.proper_file_path, @data_upload.transactable_type)
    begin
      @xml_file.parse
    rescue
      @data_upload.encountered_error = "#{$!.inspect}\n\n#{$@}"
    ensure
      @data_upload.parsing_result_log = @xml_file.get_parse_result
      @data_upload.parse_summary = @xml_file.get_summary
      @data_upload.save!
    end
  end

end

