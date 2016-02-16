require 'csv'

class DataImporter::Product::CsvFile

  MODELS = %i(user company spree/product spree/variant spree/shipping_category spree/image).freeze

  def initialize(data_upload)
    @data_upload = data_upload
    data = open(data_upload.csv_file.proper_file_path).read.encode('UTF-8', undef: :replace, replace: '')
    @csv_handle = CSV.new(data, headers: true, header_converters: :downcase, encoding: 'utf-8')
    @importable = data_upload.importable
  end

  def process_next_row
    current_row = @csv_handle.shift
    MODELS.inject({}) { |hsh, model| hsh[model] = attributes_for(model, current_row); hsh } if current_row
  end

  private

  def attributes_for(model, row)
    csv_fields_for_model(model).inject({}) do |hsh, (attr, label)|
      value = row[label.downcase]
      unless value.nil?
        if custom_attribute?(model, attr)
          hsh[:extra_properties] ||= {}
          hsh[:extra_properties][attr] = value
        else
          hsh[attr] = value
        end
      end
      hsh
    end
  end

  def custom_attribute?(model, attr)
    model == :'spree/product' && @importable.custom_attributes.map(&:name).include?(attr.to_s)
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
