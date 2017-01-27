require 'test_helper'

class MarketplaceBuilder::ExporterTest < ActiveSupport::TestCase
  EXPORT_DESTINATION_PATH = "#{Rails.root}/tmp/exported_instances"

  context 'marketplace exporter' do
    setup do
      stub_request(:get, "http://example.com/test.jpg").to_return(status: 200)

      @instance = create(:instance, name: 'ExportTestInstance', is_community: true, require_verified_user: false)
      @instance.set_context!

      Locale.create! code: 'en'
    end

    teardown do
      FileUtils.rm_rf(EXPORT_DESTINATION_PATH)
    end

    should 'export instance to files' do
      run_all_setup_methods
      MarketplaceBuilder::Exporter.new(@instance.id, EXPORT_DESTINATION_PATH).execute!
      run_all_should_export_methods
    end
  end

  def should_export_instance_basic_attributes
    yaml_content = read_exported_file('instance_attributes.yml') 

    assert_equal yaml_content['name'], 'ExportTestInstance'
    assert_equal yaml_content['is_community'], true
    assert_equal yaml_content['require_verified_user'], false
  end

  def setup_translations
    @instance.translations.create! locale: 'en', key: 'first_test_key.nested.value', value: 'First test key nested value'
    @instance.translations.create! locale: 'en', key: 'second_test_key.nested.value', value: 'Second test key nested name'
    @instance.translations.create! locale: 'pl', key: 'first_test_key.value', value: 'Testowa nazwa'
  end

  def should_export_translations
    yaml_content = read_exported_file('translations/en.yml')
    assert_equal yaml_content['en']['first_test_key']['nested']['value'], 'First test key nested value'
    assert_equal yaml_content['en']['second_test_key']['nested']['value'], 'Second test key nested name'

    yaml_content = read_exported_file('translations/pl.yml')
    assert_equal yaml_content['pl']['first_test_key']['value'], 'Testowa nazwa'
  end

  def setup_transactable_types
    type = @instance.transactable_types.create! name: 'Car'

    type.custom_validators.create! field_name: 'name', max_length: 140
    type.custom_validators.create! field_name: 'name', regex_validation: true, regex_expression: "^\\d{10}$"
    type.action_types.create! enabled: true, type: 'TransactableType::NoActionBooking', allow_no_action: true

    type.action_types.create! enabled: true, type: 'TransactableType::SubscriptionBooking', allow_no_action: true,
      pricings: [TransactableType::Pricing.new(number_of_units: 30, unit: 'day')]

    attribute = type.custom_attributes.create! name: 'description', html_tag: 'textarea', attribute_type: 'text', search_in_query: true
    attribute.custom_validators.create! field_name: 'description', regex_validation: true, regex_expression: "^\\d{10}$"

    @instance.transactable_types.create! name: 'Bike'
  end

  def should_export_transactable_types
    yaml_content = read_exported_file('transactable_types/car.yml')
    assert_equal yaml_content['name'], 'Car'
    assert_same_elements yaml_content['validation'], [{"required" => false, "field_name"=>"name", 'validation_only_on_update' => false, "regex"=>"^\\d{10}$"},
                                              {"required" => false, "field_name"=>"name", "max_length"=>140, 'validation_only_on_update' => false}]

    assert_same_elements yaml_content['action_types'], [{"enabled"=>true, "type"=>"TransactableType::SubscriptionBooking", "allow_no_action"=>true, "pricings"=>[{"number_of_units"=>30, "unit"=>"day", "min_price_cents"=>0, "max_price_cents"=>0, "order_class_name"=>"RecurringBooking", "allow_nil_price_cents"=>false}]}, {"enabled"=>true, "type"=>"TransactableType::NoActionBooking", "allow_no_action"=>true}]
    assert_same_elements yaml_content['custom_attributes'], [{"name"=>"description", "attribute_type"=>"text", "html_tag"=>"textarea", "search_in_query"=>true, "validation"=>[{"required"=>false, "field_name"=>"description", "validation_only_on_update"=>false, "regex"=>"^\\d{10}$"}]}]

    yaml_content = read_exported_file('transactable_types/bike.yml')
    assert_equal yaml_content['name'], 'Bike'
  end

  def setup_instance_profile_types
    profile_type = @instance.instance_profile_types.create! name: 'Default', profile_type: 'default'
    profile_type.custom_validators.create! field_name: 'name', max_length: 140
    profile_type.custom_validators.create! field_name: 'name', regex_validation: true, regex_expression: "^\\d{10}$"

    profile_attribute = profile_type.custom_attributes.create! name: 'description', html_tag: 'textarea', attribute_type: 'text', search_in_query: true
    profile_attribute.custom_validators.create! field_name: 'description', regex_validation: true, min_length: 5
  end

  def should_export_instance_profile_types
    yaml_content = read_exported_file('instance_profile_types/default.yml')

    assert_equal yaml_content['name'], 'Default'
    assert_same_elements yaml_content['validation'], [{"required" => false, "field_name"=>"name", 'validation_only_on_update' => false, "regex"=>"^\\d{10}$"}, {"required" => false, "field_name"=>"name", "max_length"=>140, 'validation_only_on_update' => false}]
    assert_same_elements yaml_content['custom_attributes'], [{"name"=>"description", "attribute_type"=>"text", "html_tag"=>"textarea", "search_in_query"=>true, "validation"=>[{"required"=>false, "field_name"=>"description", "validation_only_on_update"=>false, "min_length"=>5}]}]
  end

  def setup_reservation_types
    reservation_type = @instance.reservation_types.create! name: 'Booking', withdraw_invitation_when_reject: true, transactable_types: [@instance.transactable_types.first]

    creator = Utils::BaseComponentCreator.new(reservation_type)
    creator.instance_variable_set(:@form_type_class, "reservation_attributes")
    creator.create_components! [type: 'reservation_attributes', name: 'Booking form', fields: [reservation: 'guest_notes']]
  end

  def should_export_reservation_types
    yaml_content = read_exported_file('reservation_types/booking.yml')

    assert_equal yaml_content['name'], 'Booking'
    assert_equal yaml_content['transactable_types'], ['Car']
    assert_same_elements yaml_content['form_components'], [{"name"=>"Booking form", "fields"=>[{"reservation"=>"guest_notes"}], "type"=>"reservation_attributes"}]
  end

  def setup_categories
    Category.create! name: 'Extras', multiple_root_categories: true, shared_with_users: true, instance_id: @instance.id,
      transactable_types: [TransactableType.last], instance_profile_types: [InstanceProfileType.last],
      children: [Category.create!(name: "Child Seat", children: [Category.create!(name: 'test')]), Category.create!(name: "Bike Rack")]
  end

  def should_export_categories
    yaml_content = read_exported_file('categories/extras.yml')

    assert_equal yaml_content['name'], 'Extras'
    assert_equal yaml_content['multiple_root_categories'], true
    assert_equal yaml_content['shared_with_users'], true
    assert_equal yaml_content['transactable_types'], ['Bike']
    assert_equal yaml_content['instance_profile_types'], ['Default']
    assert_same_elements yaml_content['children'], [{"name"=>"Bike Rack"}, {"name"=>"Child Seat", "children"=>[{"name"=>"test"}]}]
  end

  def setup_topics
    Topic.create! name: 'test', description: 'test', instance_id: @instance.id, category: Category.last, featured: true, remote_cover_image_url: 'http://example.com/test.jpg'
  end

  def should_export_topics
    yaml_content = read_exported_file('topics/topics.yml')

    assert_equal yaml_content, {"topics"=> [{"name"=>"test", "description"=>"test", "featured"=>true, "remote_cover_image_url"=>nil}]}
  end

  def setup_pages
    Page.create! path: 'Test', content: '<h1>Hello</h1>', slug: 'test-page'
  end

  def should_export_pages
    liquid_content = read_exported_file('pages/test.liquid', :liquid)
    assert_equal liquid_content.body, '<h1>Hello</h1>'
  end

  def setup_content_holders
    ContentHolder.create! name: 'Test', content: '<h1>Hello from content holder</h1>'
  end

  def should_export_content_holders
    liquid_content = read_exported_file('content_holders/test.liquid', :liquid)
    assert_equal liquid_content.body, '<h1>Hello from content holder</h1>'
  end

  def setup_emails
    InstanceView.create!(instance_id: @instance.id, view_type: 'email', path: 'example_path/example_mailer', handler: 'liquid', format: 'html',
                         partial: false, body: 'Hello from email', locales: Locale.all)
  end

  def should_export_emails
    liquid_content = read_exported_file('mailers/example_path/example_mailer.liquid', :liquid)
    assert_equal liquid_content.body, 'Hello from email'
  end

  def setup_liquid_views
    InstanceView.create!(instance_id: @instance.id, view_type: 'view', path: 'home/index', handler: 'liquid', format: 'html',
                         partial: false, body: 'Hello from liquid view', locales: Locale.all)
  end

  def should_export_liquid_views
    liquid_content = read_exported_file('liquid_views/home/index.liquid', :liquid)
    assert_equal liquid_content.body, 'Hello from liquid view'
  end

  def setup_sms
    InstanceView.create!(instance_id: @instance.id, view_type: 'sms', path: 'example/path', handler: 'liquid', format: 'html',
                       partial: false, body: 'Hello from sms', locales: Locale.all)
  end

  def should_export_sms
    liquid_content = read_exported_file('sms/example/path.liquid', :liquid)
    assert_equal liquid_content.body, 'Hello from sms'
  end

  def setup_workflow
    workflow = Workflow.create! name: 'test workflow', instance_id: @instance.id
    workflow_step = WorkflowStep.create! workflow: workflow, name: 'test workflow', instance_id: @instance.id, associated_class: WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate
    WorkflowAlert.create! workflow_step: workflow_step, name: "test", alert_type: "email", recipient_type: "lister", template_path: "user_mailer/user_commented_on_user_update"
  end

  def should_export_workflow
    yaml_content = read_exported_file('workflows/test_workflow.yml')

    assert_equal yaml_content, {"name"=>"test workflow", "events_metadata"=>{}, "workflow_steps"=>[
      {"name"=>"test workflow",
       "associated_class"=>"WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate", 
       "workflow_alerts"=>[
         {"name"=>"test",
          "alert_type"=>"email",
          "recipient_type"=>"lister",
          "template_path"=>"user_mailer/user_commented_on_user_update",
          "delay"=>0
       }]}]}
  end

  def setup_custom_model_types
    custom_model_type = CustomModelType.create! instance_id: @instance.id, name: 'Test', transactable_types: [TransactableType.last], instance_profile_types: [InstanceProfileType.last]
    profile_attribute = custom_model_type.custom_attributes.create! name: 'description', html_tag: 'textarea', attribute_type: 'text', search_in_query: true
    profile_attribute.custom_validators.create! field_name: 'description', regex_validation: true, min_length: 5
  end

  def should_export_custom_model_types
    yaml_content = read_exported_file('custom_model_types/test.yml')

    assert_equal yaml_content, {"name"=>"Test", "custom_attributes"=>[
      {"name"=>"description",
       "attribute_type"=>"text",
       "html_tag"=>"textarea",
       "search_in_query"=>true,
       "validation"=>[
         {"required"=>false,
          "field_name"=>"description",
          "min_length"=>5,
          "validation_only_on_update"=>false
       }]}],
       "instance_profile_types"=>["Default"], "transactable_types"=>["Bike"]}
  end

  def setup_graph_queries
    @instance.graph_queries.create! name: 'test', query_string: '{}'
  end

  def should_export_graph_queries
    yaml_content = read_exported_file('graph_queries/test.graphql')

    assert_equal yaml_content, {}
  end

  def setup_custom_themes
    File.open("#{Rails.root}/tmp/main.js", "w+") { |f| f.puts "js content" }

    custom_theme = @instance.custom_themes.create! name: 'Default', in_use: false, in_use_for_instance_admins: true
    custom_theme.custom_theme_assets.create! name: 'main.js', file: File.open("#{Rails.root}/tmp/main.js"), type: 'CustomThemeAsset::ThemeJsFile'
  end

  def should_export_custom_themes
    yaml_content = read_exported_file('custom_themes/default.yml')
    assert_equal yaml_content, {"name"=>"Default", "in_use"=>false, "in_use_for_instance_admins"=>true}

    js_content = read_exported_file('custom_themes/default_custom_theme_assets/main.js')
    assert_equal js_content, 'js content'
  end

  private

  def read_exported_file(path, reader = :yml)
    if reader == :yml
      YAML.load(File.read("#{EXPORT_DESTINATION_PATH}/ExportTestInstance/#{path}"))
    elsif reader == :liquid
      MarketplaceBuilder::Creators::TemplatesCreator.load_file_with_yaml_front_matter("#{EXPORT_DESTINATION_PATH}/ExportTestInstance/#{path}", 'test')
    else
      raise 'Not implemented reader'
    end
  end

  def run_all_setup_methods
    self.class.instance_methods(false).grep(/setup_/).each {|method_sym| self.send(method_sym) }
  end

  def run_all_should_export_methods
    self.class.instance_methods(false).grep(/should_export_/).each {|method_sym| self.send(method_sym) }
  end
end
