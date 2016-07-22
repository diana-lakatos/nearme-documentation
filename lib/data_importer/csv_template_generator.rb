require 'csv'

class DataImporter::CsvTemplateGenerator < DataImporter::File

  def initialize(importable, include_user_fields = false)
    @importable = importable
    @include_user_fields = include_user_fields
    @models = if import_model == :transactable
                [:company, :location, :address, import_model, :photo]
              else
                [:company, import_model]
              end
  end

  def generate
    CSV.generate_line(required_fields)
  end

  private

  def required_fields
    (@include_user_fields ? static_fields(%i(user)) : []) + if @importable.custom_csv_fields.empty?
                                                              static_fields
    else
      custom_fields(@importable.custom_csv_fields).compact
    end
  end

  def static_fields(models = nil)
    (models || @models).inject([]) do |ar, model|
      klass = model.to_s.classify.constantize
      ar + ((model == import_model ? klass.csv_fields(@importable) : klass.csv_fields).values)
    end
  end

  def custom_fields(fields_array)
    fields_array.map do |model_field_hash|
      model, field = model_field_hash.shift
      if model.to_sym == import_model
        import_class.csv_fields(@importable)
      elsif model.to_sym.in?(@models)
        model.to_s.classify.constantize.csv_fields
      else
        {}
      end.with_indifferent_access.fetch(field, nil)
    end
  end

  def import_class
    @import_class ||= import_model.to_s.classify.constantize
  end

  def import_model
    @import_model ||= @importable.class.name.sub('Type', '').underscore.to_sym
  end

end
