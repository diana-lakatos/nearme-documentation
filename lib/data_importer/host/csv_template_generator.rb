class DataImporter::Host::CsvTemplateGenerator < DataImporter::CsvTemplateGenerator

  def initialize(importable)
    @importable = importable
    @models = if import_model == :transactable
                [:location, :address, import_model, :photo]
              else
                [import_model]
              end
  end

end

