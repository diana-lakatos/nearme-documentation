# frozen_string_literal: true
class FormAttributes
  CKEFIELDS = {
    # transactable: [:description],
    offer: [:description]
  }.freeze

  def user
    [
      :email, :phone, :avatar, :name, :first_name, :middle_name, :last_name, :approval_requests, :current_address,
      :password, :public_profile, :time_zone, :language, :mobile_number, :mobile_phone, :company_name, :tags
    ] + UserProfile.public_custom_attributes_names(PlatformContext.current.instance.default_profile_type.try(:id)).map { |k| Hash === k ? k.keys : k }.flatten +
      extra_attributes(Category.users.roots, 'Category') +
      extra_attributes(CustomModelType.users, 'Custom Model')
  end

  def seller
    [:enabled] + UserProfile.public_custom_attributes_names(PlatformContext.current.instance.seller_profile_type.try(:id)).map { |k| Hash === k ? k.keys : k }.flatten +
      extra_attributes(Category.sellers.roots, 'Category') +
      extra_attributes(CustomModelType.sellers, 'Custom Model')
  end

  def buyer
    [:enabled] + UserProfile.public_custom_attributes_names(PlatformContext.current.instance.buyer_profile_type.try(:id)).map { |k| Hash === k ? k.keys : k }.flatten +
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
      :assigned_waiver_agreement_templates
    ]
  end

  def transactable(transactable_type = nil)
    [
      :name, :description, :availability_rules, :price, :currency, :photos, :tags,
      :approval_requests, :quantity, :book_it_out, :exclusive_price, :action_rfq,
      :confirm_reservations, :capacity, :rental_shipping_type, :seller_attachments,
      :additional_charges, :minimum_booking_minutes, :deposit_amount, :shipping_info,
      :pro_bono, :package_details
    ] +
      Transactable.public_custom_attributes_names(transactable_type.id).map { |k| Hash === k ? k.keys : k }.flatten +
      extra_attributes(transactable_type.categories.roots, 'Category') +
      extra_attributes(transactable_type.custom_model_types, 'Custom Model')
  end

  def dashboard_transactable(transactable_type = nil)
    [
      :confirm_reservations, :name, :description, :location_id, :approval_requests,
      :enabled, :price, :currency, :schedule, :photos, :tags,
      :waiver_agreement_templates, :documents_upload, :quantity, :book_it_out,
      :exclusive_price, :action_rfq, :capacity, :seller_attachments,
      :additional_charges, :minimum_booking_minutes, :deposit_amount, :shipping_info,
      :collaborators, :pro_bono, :unavailable_periods, :package_details, :availability_rules
    ] +
      Transactable.public_custom_attributes_names(transactable_type.id).map { |k| Hash === k ? k.keys : k }.flatten +
      extra_attributes(transactable_type.categories.roots, 'Category') +
      extra_attributes(transactable_type.custom_model_types, 'Custom Model')
  end

  def project(transactable_type = nil)
    [
      :name, :description, :topics, :photos
    ] +
      Project.public_custom_attributes_names(transactable_type.id).map { |k| Hash === k ? k.keys : k }.flatten +
      extra_attributes(transactable_type.categories.roots, 'Category') +
      extra_attributes(transactable_type.custom_model_types, 'Custom Model')
  end

  def reservation(reservation_type = nil)
    [:address, :dates, :guest_notes, :waiver_agreements, :payments, :payment_documents,
     :billing_address, :shipping, :shipping_options, :price, :start_date, :shipping_address_google] +
      extra_attributes(reservation_type.categories.roots, 'Category') +
      reservation_type.custom_attributes.public_display.pluck(:name) +
      extra_attributes(reservation_type.custom_model_types, 'Custom Model')
  end

  def extra_attributes(collection, prefix)
    collection.map { |k| ("#{prefix} - " + k.name).to_sym }.flatten
  end
end
