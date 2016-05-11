class ShippingCategoryForm < Form

  # attr_reader :shipping_category

  # validates :name, presence: true, length: {minimum: 3}
  # validate :validate_shipping_methods, :list_of_countries_or_states_cannot_be_empty

  # delegate :shipping_methods, :name, :name=, to: :@shipping_category

  # def initialize(shipping_category, options = {})
  #   @shipping_category = shipping_category
  #   @options = options
  # end

  # def validate_shipping_methods
  #   errors.add(:shipping_methods) if @shipping_methods.blank? || !@shipping_methods.map(&:valid?).all?
  # end

  # def list_of_countries_or_states_cannot_be_empty
  #   added_to_base = false
  #   if @shipping_methods.present?
  #     @shipping_methods.each do |shipping_method|
  #       if shipping_method.try(:zones).present?
  #         shipping_method.zones.each do |zone|
  #           if zone.members.empty?
  #             if !added_to_base
  #               # We add this to prevent the form from being saved
  #               errors.add(:base, :zone_incomplete)
  #               added_to_base = true
  #             end
  #             # And we add this to get the error message in the form
  #             zone.errors.add(:kind, :members_missing)
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

  # def shipping_methods
  #   @shipping_methods
  # end

  # def assign_all_attributes
  #   build_shipping_methods
  # end

  # def submit(params)
  #   @shipping_category.is_system_profile = true if @options[:is_system_profile]

  #   store_attributes(params)
  #   if valid?
  #     save!
  #     true
  #   else
  #     assign_all_attributes
  #     false
  #   end
  # end

  # def save!
  #   @shipping_category.save!(validate: true)

  #   @shipping_methods.each do |shipping_method|
  #     shipping_method.save!(validate: true)
  #     shipping_method.zones.each do |zone|
  #       zone.save!(validate: true)
  #       zone.members.each(&:save)
  #     end
  #   end
  # end

  # def build_shipping_methods
  #   @shipping_methods ||= @shipping_category.shipping_methods.to_a
  #   5.times do
  #     hidden = @shipping_methods.blank? && @shipping_category.shipping_methods.blank? ? "0" : "1"
  #     shipping_method ||= @shipping_category.shipping_methods.build
  #     shipping_method.hidden = hidden
  #     shipping_method.calculator ||= Spree::Calculator::Shipping::FlatRate.new(preferred_amount: 0)
  #     shipping_method.zones.build(kind: "country", name: "Default - #{SecureRandom.hex}")
  #     @shipping_methods << shipping_method
  #   end
  # end

  # # This prevents a weird Rails/Spree issue causing states/countries
  # # to not get set if one of the other is set
  # def cleanup_zones_attributes(shipping_methods_attributes)
  #   result = shipping_methods_attributes

  #   zones_attributes = shipping_methods_attributes['zones_attributes']
  #   if zones_attributes.present?
  #     if zones_attributes['0'].present?
  #       if zones_attributes['0']['state_ids'].to_s.strip.present?
  #         zones_attributes['0'].delete('country_ids')
  #       else
  #         zones_attributes['0'].delete('state_ids')
  #       end
  #     end
  #   end

  #   result
  # end

  # def shipping_methods_attributes=(attributes)
  #   @shipping_methods = []
  #   attributes.each do |key, shipping_methods_attributes|
  #     next if shipping_methods_attributes["hidden"] == "1"
  #     shipping_method = @shipping_category.shipping_methods.where(id: shipping_methods_attributes["id"]).first
  #     if shipping_methods_attributes["removed"] == "1"
  #       shipping_method.try(:destroy)
  #     else
  #       if !shipping_method
  #         if shipping_methods_attributes['id'].present?
  #           shipping_method = Spree::ShippingMethod.find(shipping_methods_attributes['id'])
  #         else
  #           shipping_method = Spree::ShippingMethod.new
  #         end
  #       end

  #       shipping_methods_attributes = cleanup_zones_attributes(shipping_methods_attributes)
  #       shipping_method.assign_attributes(shipping_methods_attributes)
  #       shipping_method.shipping_categories = [@shipping_category]
  #       @shipping_methods << shipping_method
  #     end
  #   end
  # end


  # def persisted?
  #   false
  # end

end

