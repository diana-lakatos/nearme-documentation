require 'csv'

class DataImporter::Product::CsvFile

  MODELS = %i(user company industry spree/product spree/variant spree/shipping_category spree/image).freeze

  def initialize(data_upload)
    @data_upload = data_upload
    @csv_handle = CSV.open(data_upload.csv_file.proper_file_path, 'r', headers: true, header_converters: ->(h) { h.downcase })
    @importable = data_upload.importable
  end

  def process_next_row
    current_row = @csv_handle.shift
    MODELS.inject({}) { |hsh, model| hsh[model] = attributes_for(model, current_row); hsh } if current_row
  end

  private

  def attributes_for(model, row)
    csv_fields_for_model(model).inject({}) do |hsh, (attr, label)|
      hsh[attr] = row[label.downcase]
      hsh
    end
  end

  def csv_fields_for_model(model)
    klass = klass_for_model(model)
    (model == :'spree/product' ? (klass.csv_fields(@importable)) : klass.csv_fields)
  end

  def klass_for_model(model)
    @klasses ||= {}
    @klasses[model] ||= model.to_s.classify.constantize
  end

end