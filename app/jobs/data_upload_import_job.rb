class DataUploadImportJob < Job

  def after_initialize(data_upload_id)
    @data_upload_id = data_upload_id
  end

  def perform
    @data_upload = DataUpload.find(@data_upload_id)
    @xml_file = DataImporter::XmlFile.new(@data_upload.xml_file.proper_file_path, @data_upload.transactable_type)
    @xml_file.parse
  end

end
