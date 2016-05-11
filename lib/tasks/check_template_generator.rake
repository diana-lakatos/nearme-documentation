desc "Check template generator"
task check_template_generator: :environment do
  fails = []
  Instance.find_each do |instance|
    PlatformContext.current = PlatformContext.new(instance)

    TransactableType.find_each do |transactable_type|
      fails << check_custom_attributes(transactable_type)
    end
  end
  puts fails.flatten.uniq
end


def check_custom_attributes(transactable_type)
  fails = []
  models = [:location, :address, :transactable, :photo]

  transactable_type.custom_csv_fields.map do |model_field_hash|
    model, field = model_field_hash.shift
    hsh = if model.to_sym == :transactable
        Transactable.csv_fields(transactable_type)
      elsif model.to_sym.in?(models)
        model.to_s.classify.constantize.csv_fields
      else
        raise NotImplementedError.new("Unknown model for which field #{field} was defined: #{model}. Valid models: #{models.join(', ')}")
      end

    begin
      hsh.with_indifferent_access.fetch(field)
    rescue Exception => e
      fails << {model => field}
    end
    fails
  end
end
