require 'csv'

class DataImporter::CsvFile::TemplateCsvFile < DataImporter::CsvFile

  def initialize(path, transactable_type, options = {})
    @transactable_type = transactable_type
    @options = options.symbolize_keys.reverse_merge(send_invitational_email: false)
    super(path)
    @header_metadata = parse_header(@csv_handle.shift)
    @warnings = { header: [] }
  end

  def parse_header(header)
    header.map!(&:downcase)
    fields_hash = {
      user: User.csv_fields,
      company: Company.csv_fields,
      location: Location.csv_fields,
      address: Address.csv_fields,
      transactable: Transactable.csv_fields(@transactable_type),
      photo: Photo.csv_fields
    }
    @mapping_hash = fields_hash.inject({}) do |mapping_hash, model|
      mapping_hash[model[0]] = {}
      model[1].each do |attribute, label|
        mapping_hash[model[0]][attribute] = header.index(label.downcase)
      end
      mapping_hash
    end
  end

  def user_attributes
    build_attributes_hash(User)
  end

  def company_attributes
    build_attributes_hash(Company)
  end

  def location_attributes
    build_attributes_hash(Location)
  end

  def address_attributes
    build_attributes_hash(Address)
  end

  def listing_attributes
    build_attributes_hash(Transactable)
  end

  def photo_attributes
    build_attributes_hash(Photo)
  end

  def build_attributes_hash(klass)
    csv_fields = "Transactable" == klass.to_s ? klass.csv_fields(@transactable_type) : klass.csv_fields
    csv_fields.keys.inject({}) do |hash, attribute|
      if @mapping_hash[klass.name.underscore.to_sym][attribute.to_sym].present?
        hash[attribute.to_sym] = @current_row[@mapping_hash[klass.name.underscore.to_sym][attribute.to_sym]]
      end
      hash
    end
  end

end

