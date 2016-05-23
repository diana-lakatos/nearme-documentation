class FormAttributes

  CKEFIELDS = {
    # transactable: [:description],
    offer: [:description]
  }

  def user
    [
      :email, :phone, :avatar, :name, :first_name, :middle_name, :last_name, :approval_requests, :current_address,
      :password, :public_profile, :time_zone, :language, :mobile_phone
    ] + UserProfile.public_custom_attributes_names(PlatformContext.current.instance.default_profile_type.try(:id)).map { |k| Hash === k ? k.keys : k }.flatten +
    extra_attributes(Category.users.roots, 'Category') +
    extra_attributes(CustomModelType.users, 'Custom Model')
  end

  def seller
    UserProfile.public_custom_attributes_names(PlatformContext.current.instance.seller_profile_type.try(:id)).map { |k| Hash === k ? k.keys : k }.flatten +
    extra_attributes(Category.sellers.roots, 'Category') +
    extra_attributes(CustomModelType.sellers, 'Custom Model')
  end

  def buyer
    UserProfile.public_custom_attributes_names(PlatformContext.current.instance.buyer_profile_type.try(:id)).map { |k| Hash === k ? k.keys : k }.flatten +
    extra_attributes(Category.buyers.roots, 'Category') +
    extra_attributes(CustomModelType.buyers, 'Custom Model')
  end

  def company
    [
      :name,
      :url,
      :email,
      :description,
      :address,
      :payments_mailing_address
    ]
  end

  def location
    [
      :description, :email, :info, :time_zone,
      :phone, :availability_rules, :special_notes,
      :location_type, :photos, :name, :address, :administrator,
      :amenities, :assigned_waiver_agreement_templates
    ]
  end

  def transactable(transactable_type = nil)
    [
      :name, :description, :availability_rules, :price, :currency, :photos,
      :approval_requests, :quantity, :book_it_out, :exclusive_price, :action_rfq,
      :confirm_reservations, :capacity, :rental_shipping_type, :seller_attachments,
      :additional_charges, :minimum_booking_minutes, :deposit_amount
    ] +
    Transactable.public_custom_attributes_names(transactable_type.id).map { |k| Hash === k ? k.keys : k }.flatten +
    extra_attributes(transactable_type.categories.roots, 'Category') +
    extra_attributes(transactable_type.custom_model_types, 'Custom Model')
  end

  def dashboard_transactable(transactable_type = nil)
    [
      :confirm_reservations, :name, :description, :location_id, :approval_requests,
      :enabled, :amenity_types, :price, :currency, :schedule, :photos,
      :waiver_agreement_templates, :documents_upload, :quantity, :book_it_out,
      :exclusive_price, :action_rfq, :capacity, :rental_shipping_type, :seller_attachments,
      :additional_charges, :minimum_booking_minutes, :deposit_amount
    ] +
    Transactable.public_custom_attributes_names(transactable_type.id).map { |k| Hash === k ? k.keys : k }.flatten +
    extra_attributes(transactable_type.categories.roots, 'Category') +
    extra_attributes(transactable_type.custom_model_types, 'Custom Model')
  end

  def product(product_type = nil)
    [
      :name,
      :description,
      :photos,
      :price,
      :quantity,
      :integrated_shipping,
      :shipping_info,
      :action_rfq,
      :documents_upload,
      :seller_attachments,
      :additional_charges
    ] +
    Spree::Product.public_custom_attributes_names(product_type.id).map { |k| Hash === k ? k.keys : k }.flatten +
    extra_attributes(product_type.categories.roots, 'Category') +
    extra_attributes(product_type.custom_model_types, 'Custom Model')
  end

  def project(transactable_type = nil)
    [
      :name, :description, :topics, :photos
    ] +
    Project.public_custom_attributes_names(transactable_type.id).map { |k| Hash === k ? k.keys : k }.flatten +
    extra_attributes(transactable_type.categories.roots, 'Category') +
    extra_attributes(transactable_type.custom_model_types, 'Custom Model')
  end

  def offer(offer_type = nil)
    [
      :name, :description, :summary, :photos, :price, :price_cents, :currency, :seller_attachments, :documents_upload
    ] +
    Offer.public_custom_attributes_names(offer_type.id).map { |k| Hash === k ? k.keys : k }.flatten +
    extra_attributes(offer_type.categories.roots, 'Category') +
    extra_attributes(offer_type.custom_model_types, 'Custom Model')
  end

  def reservation(reservation_type = nil)
    [:address, :dates] +
    extra_attributes(reservation_type.categories.roots, 'Category') +
    reservation_type.custom_attributes.public_display.pluck(:name) +
    extra_attributes(reservation_type.custom_model_types, 'Custom Model')
  end

  def extra_attributes(collection, prefix)
    collection.map{ |k| ("#{prefix} - " + k.name).to_sym }.flatten
  end
end

