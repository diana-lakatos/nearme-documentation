require "test_helper"

class TranslationsTest < ActionDispatch::IntegrationTest

  setup do
    @admin = FactoryGirl.create(:admin)
    stub_mixpanel
    instance = Instance.first
    instance.domains << FactoryGirl.create(:domain, name: "www.example.com")
    @transactable_type = ServiceType.first
    @company = FactoryGirl.create(:company, creator: @admin)
    @location = FactoryGirl.create(:location, company: @company)
  end


  should 'should display translations in transactable form based on MPO settings' do
    post_via_redirect user_session_path, user: { email: @admin.email, password: @admin.password }
    FactoryGirl.create(:form_component_transactable)
    name_label = Translation.where(key: "#{@transactable_type.translation_namespace}.labels.name").first
    put instance_admin_settings_translations_path, instance: { translations_attributes: { '0' => { key: name_label.key, value: "Super Name for XYZ", _destroy: "false", id: name_label.id}}}
    assert_response :redirect
    post create_key_instance_admin_settings_locales_path, translation: { key: "#{@transactable_type.translation_namespace}.hints.name", value: "Very helpful hint!"}
    assert_response :redirect
    PlatformContext.current.instance.reload
    get new_dashboard_company_transactable_type_transactable_path(@transactable_type)
    assert_select 'label[for=transactable_name]', 'Super Name for XYZ'
    assert_select '.transactable_name p', 'Very helpful hint!'
    put instance_admin_settings_translations_path, instance: { translations_attributes: { '0' => { key: name_label.key, value: 'Another interesting label', _destroy: 'false', id: name_label.id}}}
    post create_key_instance_admin_settings_locales_path, translation: { key: "#{@transactable_type.translation_namespace}.hints.description", value: 'And interesting hint for description!'}
    get new_dashboard_company_transactable_type_transactable_path(@transactable_type)
    refute response.body.include?('Super Name for XYZ')
    assert_select 'label[for=transactable_name]', 'Another interesting label'
    assert_select '.transactable_description p', 'And interesting hint for description!'
  end

end
