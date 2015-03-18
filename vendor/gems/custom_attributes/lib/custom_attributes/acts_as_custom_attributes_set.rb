module CustomAttributes
  module ActsAsCustomAttributesSet
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_custom_attributes_set(options = {})
        has_many :custom_attributes, as: :target, class_name: '::CustomAttributes::CustomAttribute'

        define_method(:translation_key_suffix) do
          underscore(self.name)
        end

        define_method(:translation_key_pluralized_suffix) do
          underscore(self.target.name.pluralize)
        end

        define_method(:underscore) do |string|
          string.underscore.tr(' ', '_')
        end

      end
    end

  end
end

