module MarketplaceBuilder
  module BuilderTests
    class ShouldImportTransactableTypes < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
        @transactable_type = @instance.transactable_types.first
      end

      def execute!
        compare_transacable_types
        compare_transactable_type_custom_attributes
      end

      private

      def compare_transacable_types
        assert_equal 1, @instance.transactable_types.count

        assert_equal 'Car', @transactable_type.name
        assert_equal '/:transactable_type_id/:id', @transactable_type.show_path_format

        assert_equal 1, @transactable_type.custom_validators.count
        assert_equal 'name', @transactable_type.custom_validators.first.field_name
        assert_equal 140, @transactable_type.custom_validators.first.validation_rules['length']['maximum']

        assert_equal 2, @transactable_type.action_types.count
        assert_equal 'TransactableType::NoActionBooking', @transactable_type.action_types.first.type
        assert @transactable_type.action_types.first.allow_no_action
      end

      def compare_transactable_type_custom_attributes
        assert_equal 3, @transactable_type.custom_attributes.count
        description, summary, salary = @transactable_type.custom_attributes.order(:id)

        assert_equal 'description', description.name
        assert_equal 'text', description.attribute_type
        assert_equal 'description', description.custom_validators.first.field_name
        assert_equal 5000, description.custom_validators.first.validation_rules['length']['maximum']

        assert_equal 'summary', summary.name
        assert_equal 'text', summary.attribute_type
        assert_equal 'summary', summary.custom_validators.first.field_name
        assert_equal 140, summary.custom_validators.first.validation_rules['length']['maximum']

        assert_equal 'salary', salary.name
        assert_equal 'float', salary.attribute_type
        refute salary.public
      end
    end
  end
end
