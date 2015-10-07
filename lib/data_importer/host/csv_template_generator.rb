class DataImporter::Host::CsvTemplateGenerator < DataImporter::CsvTemplateGenerator

  def initialize(importable)
    @importable = importable
    @models = if import_model == :transactable
                [:company, :location, :address, import_model, :photo]
              else
                [:company, import_model, :'spree/variant', :'spree/shipping_category', :'spree/image']
              end
  end

end

