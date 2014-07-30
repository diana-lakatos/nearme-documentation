module TransactableType::CustomAttributesCaster
  extend ActiveSupport::Concern

  included do

    def set_custom_attributes(store_accessor_name = :properties)
      metaclass = class << self; self; end
      hstore_attributes = transactable_type_attributes_names_types_hash
      metaclass.class_eval do
        store_accessor store_accessor_name, hstore_attributes.keys
      end
      transactable_type_attributes_names_types_hash.each do |key, type|
        next unless type == :boolean
        metaclass.class_eval do
          define_method("#{key}?") do
            send(key)
          end
        end
      end

    end

    def read_store_attribute(*args)
      if (type = transactable_type_attributes_names_types_hash[args[1].to_sym]).present?
        custom_property_type_cast(super, type)
      else
        super
      end
    end

    def custom_property_type_cast(value, type)
      klass = ActiveRecord::ConnectionAdapters::Column

      return nil if value.nil?
      case type.to_sym
      when :string, :text        then value
      when :integer              then value.to_i rescue value ? 1 : 0
      when :float                then value.to_f
      when :decimal              then klass.value_to_decimal(value)
      when :datetime, :timestamp then klass.string_to_time(value).in_time_zone
      when :time                 then klass.string_to_dummy_time(value)
      when :date                 then klass.string_to_date(value)
      when :binary               then klass.binary_to_string(value)
      when :boolean              then klass.value_to_boolean(value)
      else value
      end
    end
  end

end

