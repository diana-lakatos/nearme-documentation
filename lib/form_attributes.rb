class FormAttributes

  CKEFIELDS = {
    transactable: [:description],
    offer: [:description]
  }

  def user
    [
      :email, :phone, :avatar, :name, :first_name, :middle_name, :last_name, :approval_requests, :current_address,
      :password, :public_profile, :time_zone, :language
    ] + UserProfile.public_custom_attributes_names(PlatformContext.current.instance.default_profile_type.try(:id)).map { |k| Hash === k ? k.keys : k }.flatten +
    Category.users.roots.map { |k| ('Category - ' + k.name).to_sym }.flatten
  end

  def seller
    UserProfile.public_custom_attributes_names(PlatformContext.current.instance.seller_profile_type.try(:id)).map { |k| Hash === k ? k.keys : k }.flatten +
    Category.sellers.roots.map { |k| ('Category - ' + k.name).to_sym }.flatten
  end

  def buyer
    UserProfile.public_custom_attributes_names(PlatformContext.current.instance.buyer_profile_type.try(:id)).map { |k| Hash === k ? k.keys : k }.flatten +
    Category.buyers.roots.map { |k| ('Category - ' + k.name).to_sym }.flatten
  end

  def company
    [
      :name,
      :url,
      :email,
      :description,
      :address,
      :industries,
      :payments_mailing_address
    ]
  end

  def location
    [
      :description, :email, :info, :time_zone,
      :phone, :availability_rules, :special_notes,
      :location_type, :photos, :name, :address,
    ]
  end

  def transactable(transactable_type = nil)
    [
      :name, :description, :availability_rules, :price, :currency, :photos,
      :approval_requests, :quantity, :book_it_out, :exclusive_price, :action_rfq,
      :confirm_reservations, :capacity, :rental_shipping_type, :seller_attachments,
      :additional_charges, :minimum_booking_minutes
    ] +
    Transactable.public_custom_attributes_names(transactable_type.id).map { |k| Hash === k ? k.keys : k }.flatten +
    transactable_type.categories.roots.map { |k| ('Category - ' + k.name).to_sym }.flatten
  end

  def dashboard_transactable(transactable_type = nil)
    [
      :confirm_reservations, :name, :description, :location_id, :approval_requests,
      :enabled, :amenity_types, :price, :currency, :schedule, :photos,
      :waiver_agreement_templates, :documents_upload, :quantity, :book_it_out,
      :exclusive_price, :action_rfq, :capacity, :rental_shipping_type, :seller_attachments,
      :additional_charges, :minimum_booking_minutes
    ] +
    Transactable.public_custom_attributes_names(transactable_type.id).map { |k| Hash === k ? k.keys : k }.flatten +
    transactable_type.categories.roots.map { |k| ('Category - ' + k.name).to_sym }.flatten
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
    product_type.categories.roots.map { |k| ('Category - ' + k.name).to_sym }.flatten
  end

  def project(transactable_type = nil)
    [
      :name, :description, :topics, :photos
    ] +
    Project.public_custom_attributes_names(transactable_type.id).map { |k| Hash === k ? k.keys : k }.flatten
  end

  def offer(offer_type = nil)
    [
      :name, :description, :summary, :photos, :price, :price_cents, :currency, :seller_attachments, :documents_upload
    ] +
    Offer.public_custom_attributes_names(offer_type.id).map { |k| Hash === k ? k.keys : k }.flatten +
    offer_type.categories.roots.map { |k| ('Category - ' + k.name).to_sym }.flatten
  end

  def reservation(reservation_type = nil)
    reservation_type.custom_attributes.public_display.pluck(:name)
  end
end

