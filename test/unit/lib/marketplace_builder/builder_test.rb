require 'test_helper'

class MarketplaceBuilder::BuilderTest < ActiveSupport::TestCase
  EXAMPLE_MARKETPLACE_PATH = "#{Rails.root}/test/unit/lib/marketplace_builder/example_marketplace/"

  context 'marketplace builder' do
    setup do
      stub_request(:get, "https://example_url.jpg").to_return(status: 200)
      @instance = create(:instance)

      MarketplaceBuilder::Builder.new(@instance.id, EXAMPLE_MARKETPLACE_PATH, MarketplaceBuilder::Loader::AVAILABLE_CREATORS_LIST).execute!
      @instance.reload
    end

    should 'import all files' do
      run_all_should_import_methods
    end
  end

  def should_set_instance_basic_attributes
    assert_equal 'example_marketplace', @instance.name
    assert @instance.is_community
    assert_equal false, @instance.require_verified_user
  end

  def should_import_translations
    assert_includes @instance.translations.where(locale: :en).pluck(:key, :value),
      ["first_test_key", "First test name"]

    assert_includes @instance.translations.where(locale: :en).pluck(:key, :value),
      ["second_test_key", "Second test name"]

    assert_includes @instance.translations.where(locale: :pl).pluck(:key, :value),
      ["first_test_key", "Testowa nazwa"]

    assert_includes @instance.translations.where(locale: :pl).pluck(:key, :value),
      ["second_test_key", "Druga testowa nazwa"]
  end

  def should_import_transacable_types
    assert_equal 1, @instance.transactable_types.count
    transactable_type = @instance.transactable_types.first

    assert_equal 'Car', transactable_type.name
    assert_equal '/:transactable_type_id/:id', transactable_type.show_path_format

    assert_equal 1, transactable_type.custom_validators.count
    assert_equal 'name', transactable_type.custom_validators.first.field_name
    assert_equal 140, transactable_type.custom_validators.first.validation_rules['length']['maximum']

    assert_equal 2, transactable_type.action_types.count
    assert_equal 'TransactableType::NoActionBooking', transactable_type.action_types.first.type
    assert transactable_type.action_types.first.allow_no_action
  end

  def should_import_transactable_type_custom_attributes
    transactable_type = @instance.transactable_types.first
    first_custom_attribute = transactable_type.custom_attributes.first
    second_custom_attribute = transactable_type.custom_attributes.second

    assert_equal 2, transactable_type.custom_attributes.count
    assert_equal 'description', first_custom_attribute.name
    assert_equal 'text', first_custom_attribute.attribute_type

    assert_equal 'description', first_custom_attribute.custom_validators.first.field_name
    assert_equal 5000, first_custom_attribute.custom_validators.first.validation_rules['length']['maximum']

    assert_equal 'summary', second_custom_attribute.name
    assert_equal 'text', second_custom_attribute.attribute_type

    assert_equal 'summary', second_custom_attribute.custom_validators.first.field_name
    assert_equal 140, second_custom_attribute.custom_validators.first.validation_rules['length']['maximum']
  end

  def should_import_instance_profile_types
    assert_equal 1, @instance.instance_profile_types.count
    assert_equal 6, @instance.instance_profile_types.first.custom_attributes.count
  end

  def should_import_reservation_types
    assert_equal 2, @instance.reservation_types.count
    assert_equal 1, @instance.reservation_types.last.form_components.count
  end

  def should_import_categories
    last_3_categories = Category.last(3)
    assert_equal last_3_categories.map(&:name), ['Extras', 'Child Seat', 'Bike Rack']
  end

  def should_import_topics
    last_3_topics = Topic.last(3)
    assert_equal last_3_topics.map(&:name), ['2017 Convention', 'Ask a Keepsake Artist', 'Featured Artist']
  end

  def should_import_pages
    last_page = Page.last

    assert_equal last_page.path, 'Test page'
    assert_equal last_page.content, '<h1>Test!</h1>'
  end

  def should_import_workflow
    workflow = Workflow.last
    workflow_step = WorkflowStep.last
    workflow_alert = WorkflowAlert.last

    assert_equal workflow.name, 'test workflow'
    assert_equal workflow.workflow_steps.count, 1

    assert_equal workflow_step.name, 'test step'
    assert_equal workflow_step.associated_class, 'WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate'
    assert_equal workflow_step.workflow_alerts.count, 1

    assert_equal workflow_alert.name, 'test alert'
    assert_equal workflow_alert.alert_type, 'email'
    assert_equal workflow_alert.recipient_type, 'lister'
    assert_equal workflow_alert.template_path, 'user_mailer/user_commented_on_user_update'
  end

  def should_import_action_type_with_pricing
    assert_equal 1, @instance.transactable_types.first.action_types.last.pricings.count
    pricing =  @instance.transactable_types.first.action_types.last.pricings.first

    assert_equal pricing.number_of_units, 30
    assert_equal pricing.unit, 'day'
    assert_equal pricing.order_class_name, 'RecurringBooking'
    assert_equal pricing.allow_nil_price_cents, false
  end

  def should_import_custom_themes
    assert_equal 1, @instance.custom_themes.count
    custom_theme = @instance.custom_themes.first

    assert_equal custom_theme.name, 'Default'
    assert_equal custom_theme.in_use, false
    assert_equal custom_theme.in_use_for_instance_admins, false

    assert_equal 1, custom_theme.custom_theme_assets.count
    custom_asset = custom_theme.custom_theme_assets.first

    assert_equal custom_asset.name, 'application.css'
    assert_equal custom_asset.type, 'CustomThemeAsset::ThemeCssFile'
    assert_includes custom_asset.file.read, 'h1 { font-size: 100px }'
  end

  def should_import_rating_system
    assert_equal 1, @instance.rating_systems.count
    rating_system = @instance.rating_systems.first

    assert_equal rating_system.subject, 'host'
    assert_equal rating_system.active, true
    assert_equal rating_system.transactable_type.name, 'Car'

    rating_question = rating_system.rating_questions.first
    assert_equal rating_question.text, 'Example question?'

    rating_hints = rating_system.rating_hints
    assert_equal rating_hints.first.value, '2'
    assert_equal rating_hints.first.description, 'Good'
    assert_equal rating_hints.last.value, '1'
    assert_equal rating_hints.last.description, 'Bad'
  end

  private

  def run_all_should_import_methods
    self.class.instance_methods(false).grep(/should_import_/).each {|method_sym| self.send(method_sym) }
  end
end
