class FormAttributes

  def user
    [
      :phone, :job_title, :avatar,
      :biography, :facebook_url, :twitter_url,
      :linkedin_url, :instagram_url, :skills_and_interests, :name,
      :first_name, :middle_name, :last_name, :gender,
      :drivers_licence_number, :gov_number, :approval_requests
    ] + User.public_custom_attributes_names(InstanceProfileType.first.try(:id))
  end

  def company
    [
      :name,
      :url,
      :email,
      :description,
      :address,
      :industries,
      :payments_mailing_address,
      :paypal_email,
      :bank_owner_name,
      :bank_routing_number,
      :bank_account_number,
    ]
  end

  def location
    [
      :description, :email, :info, :currency,
      :phone, :availability_rules, :special_notes,
      :location_type, :photos, :name, :address,
    ]
  end

  def transactable(transactable_type = nil)
    [
      :availability_rules, :price, :photos, :approval_requests, :quantity, :book_it_out
    ] +
    Transactable.public_custom_attributes_names(transactable_type.id).map { |k| Hash === k ? k.keys : k }.flatten
  end

  def dashboard_transactable(transactable_type = nil)
    [
      :location_id, :approval_requests, :enabled, :amenity_types, :price, :schedule,
      :photos, :waiver_agreement_templates, :documents_upload, :quantity, :book_it_out
    ] +
    Transactable.public_custom_attributes_names(transactable_type.id).map { |k| Hash === k ? k.keys : k }.flatten
  end

  def product(product_type = nil)
    Spree::Product.public_custom_attributes_names(product_type.id).map { |k| Hash === k ? k.keys : k }.flatten
  end
end

