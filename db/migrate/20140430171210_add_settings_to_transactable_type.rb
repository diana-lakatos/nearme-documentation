class AddSettingsToTransactableType < ActiveRecord::Migration

  class TransactableType < ActiveRecord::Base
    serialize :pricing_options, Hash
    serialize :pricing_validation, Hash
  end

  class Instance < ActiveRecord::Base
    serialize :pricing_options, Hash
    has_many :transactable_types
  end

  def up
    add_column :transactable_types, :pricing_options, :text
    add_column :transactable_types, :pricing_validation, :text
    add_column :transactable_type_attributes, :internal, :boolean, default: false

    Instance.all.each do |instance|
      tp = instance.transactable_types.first
      pricing_validation = {}
      instance.pricing_options.each do |k, v|
        if v.to_i == 1
          pricing_validation[k.to_s] = {} if instance.respond_to?("min_#{k}_price_cents")
          pricing_validation[k.to_s]["min"] = instance.send("min_#{k}_price_cents") if instance.respond_to?("min_#{k}_price_cents")
          pricing_validation[k.to_s]["max"] = instance.send("max_#{k}_price_cents") if instance.respond_to?("max_#{k}_price_cents")
        end
      end
      tp.update_attribute(:pricing_options, instance.pricing_options)
      tp.update_attribute(:pricing_validation, pricing_validation) if tp
    end
  end

  def down
    remove_column :transactable_types, :pricing_options
    remove_column :transactable_types, :pricing_validation
    remove_column :transactable_type_attributes, :internal
  end
end
