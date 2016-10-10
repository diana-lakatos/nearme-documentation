require 'csv'

class DataImporter::Host::CsvFile::TemplateCsvFile < DataImporter::CsvFile::TemplateCsvFile
  def initialize(data_upload)
    @user = data_upload.uploader
    @company = @user.companies.first || @user.companies.create(name: @user.name, creator: @user)
    @company.update_attribute(:creator, @user) if @company.creator.nil?
    @company.update_attribute(:external_id, @company.creator.email)

    super(data_upload)
  end

  def parse_header(header)
    return {} if header.nil?
    header.map!(&:downcase)
    fields_hash = {
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
    {
      email: @user.email,
      name: @user.name
    }
  end

  def company_attributes
    {
      name: @company.name,
      url: @company.url,
      email: @company.email,
      external_id: @company.external_id
    }
  end
end
