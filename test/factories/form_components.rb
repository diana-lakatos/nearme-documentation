FactoryGirl.define do
  factory :form_component do
    sequence(:name) { |n| "Section #{n}" }
    form_componentable { TransactableType.first.presence || FactoryGirl.create(:transactable_type_listing) }
    form_type { FormComponent::SPACE_WIZARD }

    form_fields { [{'company' => 'name'}, {'company' => 'address'}, {'company' => 'industries'}, {'location' => 'name'}, {'location' => 'description'}, {'location' => 'phone'}, {'location' => 'location_type'}, {'location' => 'address'}, { 'transactable' => 'price' }, {'transactable' => 'description'}, { 'transactable' => 'photos' }, {'transactable' => 'quantity'}, { 'transactable' => 'name' }, { 'transactable' => 'listing_type' }, { 'user' => 'phone'}, { 'user' => 'approval_requests'}, { 'user' => 'first_name' }, { 'user' => 'last_name' } ] }

    factory :form_component_transactable do
      form_type { FormComponent::TRANSACTABLE_ATTRIBUTES }

      form_fields { [ {'transactable' => 'schedule'},{'transactable' => 'location_id'}, { 'transactable' => 'price' }, {'transactable' => 'description'}, { 'transactable' => 'photos' }, {'transactable' => 'quantity'}, { 'transactable' => 'name' }, { 'transactable' => 'listing_type' }, { 'transactable' => 'waiver_agreement_templates'}, {'transactable' => 'documents_upload'} ] }
    end

    factory :form_component_instance_profile_type do
      form_type { FormComponent::INSTANCE_PROFILE_TYPES }

      form_fields { [
        { "user" => "public_profile" }, { "user" => "password" }, { "user" => "industries" }, { "user" => "email" }, { "user" => "phone" }, { "user" => "job_title" }, { "user" => "avatar" }, { "user" => "biography" }, { "user" => "facebook_url" },
        { "user" => "twitter_url" }, { "user" => "linkedin_url" }, { "user" => "instagram_url" }, { "user" => "skills_and_interests" },
        { "user" => "name" }, { "user" => "first_name" }, { "user" => "middle_name" }, { "user" => "last_name" }, { "user" => "gender" },
        { "user" => "drivers_licence_number" }, { "user" => "gov_number" }, { "user" => "approval_requests" }, { "user" => "google_plus_url" }, { "user" => "degree"},
        { "user" => "language" }, { "user" => "time_zone" }, { "user" => "current_location" }, { "user" => "company_name" }
      ]}
    end


  end

end
