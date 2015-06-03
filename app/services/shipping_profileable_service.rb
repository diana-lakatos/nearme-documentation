class ShippingProfileableService

  def initialize(company, user)
    @company = company
    @user = user
  end

  def clone!
    if @company.blank?
      existing_shipping_categories_ids = Spree::ShippingCategory.not_system_profiles.where(user_id: @user.id).collect(&:from_system_shipping_category_id)
    else
      existing_shipping_categories_ids = @company.shipping_categories.not_system_profiles.collect(&:from_system_shipping_category_id)
    end

    system_shipping_categories_ids = Spree::ShippingCategory.enabled_system_profiles.collect(&:id)
    ids_not_existing = system_shipping_categories_ids - existing_shipping_categories_ids
    system_shipping_categories_to_be_created = Spree::ShippingCategory.where('id in (?)', ids_not_existing)

    system_shipping_categories_to_be_created.each do |shipping_category_to_copy|
      shipping_category = shipping_category_to_copy.dup
      shipping_category.is_system_profile = false
      shipping_category.from_system_shipping_category_id = shipping_category_to_copy.id
      shipping_category.company_id = @company.try(:id)
      shipping_category.user_id = @user.id
      shipping_category.save!

      shipping_category_to_copy.shipping_methods.each do |shipping_method_to_copy|
        shipping_method = shipping_method_to_copy.dup
        shipping_method.company_id = @company.try(:id)
        shipping_method.user_id = @user.id

        new_calculator = shipping_method_to_copy.calculator.dup
        new_calculator.company_id = @company.try(:id)
        new_calculator.user_id = @user.id
        shipping_method.calculator = new_calculator

        shipping_method.shipping_categories = [shipping_category]

        shipping_method.save!

        shipping_method_to_copy.zones.each do |zone_to_copy|
          zone = zone_to_copy.dup
          zone.company_id = @company.try(:id)
          zone.user_id = @user.id
          zone.name = "Shipping Zone #{self.get_random_string_for_id}"
          zone.shipping_method_ids = [shipping_method.id]

          if zone_to_copy.state_ids.blank?
            zone.country_ids = zone_to_copy.country_ids
          else
            zone.state_ids = zone_to_copy.state_ids
          end

          zone.save!
        end
      end
    end
  end

  def get_random_string_for_id
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...25).map { o[rand(o.length)] }.join
  end

end
