class DataImporter::Host::CsvTemplateGenerator < DataImporter::CsvTemplateGenerator

  private

  def user_fields
    raise NotImplementedError
  end

  def company_fields
    raise NotImplementedError
  end

  def static_fields
    location_fields.values + address_fields.values + transactable_fields.keys.sort.map { |k| transactable_fields[k] } + photo_fields.values
  end

end

