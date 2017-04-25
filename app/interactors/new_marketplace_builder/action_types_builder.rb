# frozen_string_literal: true
module NewMarketplaceBuilder
  module ActionTypesBuilder
    def update_action_types_for_object(object, attributes)
      attributes ||= {}
      unused_attrs = if attributes.empty?
                       object.action_types
                     else
                       object.action_types.where('type NOT IN (?)', attributes.map { |attr| attr['type'] })
                     end

      unused_attrs.destroy_all

      attributes.each do |attribute|
        attribute = attribute.symbolize_keys
        type = attribute.delete(:type)

        create_action_type(object, type, default_action_properties.merge(attribute))
      end
    end

    def create_action_type(object, type, hash)
      hash = hash.with_indifferent_access
      action_type = object.action_types.where(type: type).first_or_initialize
      action_type = action_type.becomes(type.constantize)

      pricings = hash.delete(:pricings) || []

      action_type.assign_attributes(hash)
      create_pricings(action_type, pricings)
      action_type.save!

      action_type
    end

    def default_action_properties
      {
        enabled: true,
        allow_no_action: false
      }
    end

    def create_pricings(action_type, pricings)
      unused_attrs = if pricings.empty?
                       action_type.pricings
                     else
                       action_type.pricings.all.select do |pricing|
                         pricings.none?{ |p|  pricing.units_to_s == [p[:number_of_units],p[:unit]].join('_') }
                       end
                     end

      unused_attrs.each(&:destroy)
      pricings.each do |pricing_attrs|
        pricing = action_type.pricings.where(number_of_units: pricing_attrs[:number_of_units], unit: pricing_attrs[:unit]).first_or_initialize
        pricing.assign_attributes(pricing_attrs)
        pricing.save! if action_type.persisted?
      end
    end
  end
end
