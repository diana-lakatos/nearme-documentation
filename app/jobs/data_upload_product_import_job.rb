class DataUploadProductImportJob < Job

  include Job::LongRunning

  def after_initialize(data_upload_id)
    @data_upload_id = data_upload_id
  end

  def perform
    @data_upload = DataUpload.find(@data_upload_id)
    @data_upload.import! unless @data_upload.importing?
    product_csv = csv_parser_class.new(@data_upload)
    DataImporter::Product::Importer.new(@data_upload, product_csv).import
  end

  def csv_parser_class
    DataImporter::Product::CsvFile
  end


end
