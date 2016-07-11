require 'csv'

class DataImporter::CsvFile::TemplateCsvFile < DataImporter::CsvFile

  def initialize(data_upload, *csv_fields_to_check_for)
    @importable = data_upload.importable
    @options = data_upload.options.symbolize_keys.reverse_merge(send_invitational_email: false, sync_mode: false)
    if csv_fields_to_check_for.present?
      @csv_handle, invalid_rows = DataImporter::CsvFileValidator.new(data_upload.csv_file.proper_file_path, *csv_fields_to_check_for).strip_invalid_rows
      data_upload.update_column(:parsing_result_log, invalid_rows.join("\n")) unless invalid_rows.blank?
    else
      super(data_upload.csv_file.proper_file_path)
    end
    @header_metadata = parse_header(@csv_handle.shift)
    @warnings = { header: [] }
    @csv_attributes = {}
  end

  def parse_header(header)
    header.map!(&:downcase)
    fields_hash = {
      user: User.csv_fields,
      company: Company.csv_fields,
      location: Location.csv_fields,
      address: Address.csv_fields,
      transactable: Transactable.csv_fields(@importable),
      photo: Photo.csv_fields
    }
    # maps attributes of models to index in csv - like user name is in column 0, user email in column 1 etc
    @mapping_hash = fields_hash.inject({}) do |mapping_hash, model|
      mapping_hash[model[0]] = {}
      model[1].each do |attribute, label|
        mapping_hash[model[0]][attribute] = header.index(label.downcase)
      end
      mapping_hash
    end
  end

  def user_attributes
    build_attributes_hash(User, :user)
  end

  def company_attributes
    build_attributes_hash(Company, :company)
  end

  def location_attributes
    build_attributes_hash(Location, :location)
  end

  def address_attributes
    build_attributes_hash(Address, :address)
  end

  def listing_attributes
    build_attributes_hash(Transactable, :transactable)
  end

  def photo_attributes
    build_attributes_hash(Photo, :photo)
  end

  def build_attributes_hash(klass, sym)
    @csv_attributes[sym] ||= (sym == :transactable ? klass.csv_fields(@importable) : klass.csv_fields).keys
    @csv_attributes[sym].inject({}) do |hash, attribute|
      if @mapping_hash[sym][attribute.to_sym].present?
        hash[attribute.to_sym] = @current_row[@mapping_hash[sym][attribute.to_sym]]
      end
      hash
    end
  end

end

