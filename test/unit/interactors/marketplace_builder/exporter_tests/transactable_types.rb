require_relative 'basic'

module MarketplaceBuilder
  module ExporterTests
    class ShouldExportTransactableTypes < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        type = @instance.transactable_types.create! name: 'Car'

        type.custom_validators.create! field_name: 'name', max_length: 140
        type.custom_validators.create! field_name: 'name', regex_validation: true, regex_expression: '^\\d{10}$'

        type.action_types.create! enabled: true, type: 'TransactableType::NoActionBooking', allow_no_action: true
        type.action_types.create! enabled: true, type: 'TransactableType::SubscriptionBooking', allow_no_action: true,
          pricings: [TransactableType::Pricing.new(number_of_units: 30, unit: 'day')]

        attribute = type.custom_attributes.create! name: 'description', html_tag: 'textarea', attribute_type: 'text', search_in_query: true
        attribute.custom_validators.create! field_name: 'description', regex_validation: true, regex_expression: '^\\d{10}$'
        type.custom_attributes.create! name: 'salary', attribute_type: 'float', public: false

        @instance.transactable_types.create! name: 'Bike'
      end

      def execute!
        yaml_content = read_exported_file('transactable_types/car.yml')
        assert_equal yaml_content['name'], 'Car'
        assert_same_elements yaml_content['validation'], [{ 'required' => false, 'field_name' => 'name', 'validation_only_on_update' => false, 'regex' => '^\\d{10}$' },
                                                          { 'required' => false, 'field_name' => 'name', 'max_length' => 140, 'validation_only_on_update' => false }]

        assert_same_elements yaml_content['action_types'], [{ 'enabled' => true, 'type' => 'TransactableType::SubscriptionBooking', 'allow_no_action' => true, 'pricings' => [{ 'number_of_units' => 30, 'unit' => 'day', 'min_price_cents' => 0, 'max_price_cents' => 0, 'order_class_name' => 'RecurringBooking', 'allow_nil_price_cents' => false }] }, { 'enabled' => true, 'type' => 'TransactableType::NoActionBooking', 'allow_no_action' => true }]
        assert_same_elements yaml_content['custom_attributes'], [
          { 'name' => 'salary', 'attribute_type' => 'float', "input_html_options"=>{}, 'public' => false, "search_in_query"=>false, "searchable"=>false },
          { 'name' => 'description', 'attribute_type' => 'text', 'html_tag' => 'textarea', 'search_in_query' => true, 'searchable' => false, 'input_html_options' => {}, 'public' => true, 'validation' => [{ 'required' => false, 'field_name' => 'description', 'validation_only_on_update' => false, 'regex' => '^\\d{10}$' }] },
        ]

        yaml_content = read_exported_file('transactable_types/bike.yml')
        assert_equal yaml_content['name'], 'Bike'
      end
    end
  end
end
