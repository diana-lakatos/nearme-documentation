class DataImporter::Host::CsvTemplateGenerator < DataImporter::CsvTemplateGenerator

  def initialize(importable)
    @importable = importable
    @models = if import_model == :transactable
                [:location, :address, import_model, :photo]
              else
                [import_model, :'spree/variant', :'spree/shipping_category', :'spree/image']
              end
  end

end

