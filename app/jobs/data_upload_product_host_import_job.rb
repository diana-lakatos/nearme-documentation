class DataUploadProductHostImportJob < DataUploadProductImportJob

  def csv_parser_class
    DataImporter::Product::Host::CsvFile
  end

end
