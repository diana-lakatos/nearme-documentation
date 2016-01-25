FactoryGirl.define do
  factory :form_component do
    sequence(:name) { |n| "Section #{n}" }
    form_componentable { ServiceType.first.presence || FactoryGirl.create(:transactable_type_listing) }
    form_type { FormComponent::SPACE_WIZARD }

    form_fields { [{'company' => 'name'}, {'company' => 'address'}, {'company' => 'industries'}, {'location' => 'name'}, {'location' => 'description'}, {'location' => 'phone'}, {'location' => 'location_type'}, {'location' => 'address'}, { 'transactable' => 'price' }, {'transactable' => 'description'}, { 'transactable' => 'photos' }, {'transactable' => 'quantity'}, { 'transactable' => 'name' }, { 'transactable' => 'listing_type' }, { 'user' => 'phone'}, { 'user' => 'approval_requests'}, { 'user' => 'first_name' }, { 'user' => 'last_name' } ] }

    factory :form_component_product_wizard do
      form_type { FormComponent::SPACE_WIZARD }
      form_componentable { Spree::ProductType.first.presence || FactoryGirl.create(:product_type) }
      form_fields { [{'company' => 'name'}, {'company' => 'address'}, { 'product' => 'name'}, { 'product' => 'description'}, { 'product' => 'photos'}, { 'product' => 'action_rfq' }, { 'product' => 'price'}, { 'product' => 'quantity'}, { 'product' => 'integrated_shipping'}, { 'product' => 'documents_upload'}, {'product' => 'shipping_info'}] }
    end

    factory :form_component_product do
      form_type { FormComponent::PRODUCT_ATTRIBUTES }
      form_componentable { Spree::ProductType.first.presence || FactoryGirl.create(:product_type) }
      form_fields { [{'product' => 'additional_charges'}, { 'product' => 'name'}, { 'product' => 'description'}, { 'product' => 'photos'}, { 'product' => 'action_rfq' }, { 'product' => 'price'}, { 'product' => 'quantity'}, { 'product' => 'integrated_shipping'}, { 'product' => 'documents_upload'}, {'product' => 'shipping_info'}] + form_componentable.categories.map {|c| [ {'product' => "Category - #{c.name}"} ] }}
    end

    factory :form_component_transactable do
      form_type { FormComponent::TRANSACTABLE_ATTRIBUTES }

      form_fields { [ {'transactable' => 'additional_charges'},{'transactable' => 'schedule'},{'transactable' => 'location_id'}, { 'transactable' => 'price' }, {'transactable' => 'description'}, { 'transactable' => 'photos' }, {'transactable' => 'quantity'}, { 'transactable' => 'name' }, { 'transactable' => 'listing_type' }, { 'transactable' => 'waiver_agreement_templates'}, {'transactable' => 'documents_upload'} ] }
    end

    factory :form_component_with_user_custom_attributes do
      form_fields { [ {'user' => 'user_custom_attribute'} ] }
    end

    factory :form_component_instance_profile_type do
      form_type { FormComponent::INSTANCE_PROFILE_TYPES }

      form_fields { [
        { "user" => "public_profile" }, { "user" => "password" }, { "user" => "industries" }, { "user" => "email" }, { "user" => "phone" }, { "user" => "job_title" }, { "user" => "avatar" }, { "user" => "biography" }, { "user" => "facebook_url" },
        { "user" => "twitter_url" }, { "user" => "linkedin_url" }, { "user" => "instagram_url" }, { "user" => "skills_and_interests" },
        { "user" => "name" }, { "user" => "first_name" }, { "user" => "middle_name" }, { "user" => "last_name" }, { "user" => "gender" },
        { "user" => "drivers_licence_number" }, { "user" => "gov_number" }, { "user" => "approval_requests" }, { "user" => "google_plus_url" }, { "user" => "degree"},
        { "user" => "language" }, { "user" => "time_zone" }, { "user" => "company_name" }
      ]}
    end

    factory :form_component_instance_profile_type_seller do
      form_type { FormComponent::SELLER_PROFILE_TYPES }
      form_fields { []}
    end

    factory :form_component_instance_profile_type_buyer do
      form_type { FormComponent::BUYER_PROFILE_TYPES }
      form_fields { []}
    end
  end
end

