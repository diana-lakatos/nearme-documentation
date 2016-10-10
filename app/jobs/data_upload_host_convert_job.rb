class DataUploadHostConvertJob < DataUploadConvertJob
  protected

  def csv_file
    @csv_file ||= DataImporter::Host::CsvFile::TemplateCsvFile.new(@data_upload)
  end
end
