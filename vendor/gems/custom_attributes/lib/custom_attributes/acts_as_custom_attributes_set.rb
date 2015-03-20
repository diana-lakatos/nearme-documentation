module CustomAttributes
  module ActsAsCustomAttributesSet
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_custom_attributes_set(options = {})
        options = options.merge(as: :target, class_name: '::CustomAttributes::CustomAttribute').reverse_merge(dependent: :destroy)
        has_many :custom_attributes, options

        define_method(:translation_key_suffix) do
          underscore(self.name)
        end

        define_method(:translation_key_suffix_was) do
          underscore(self.name_was)
        end

        define_method(:translation_key_pluralized_suffix) do
          underscore(self.name.pluralize)
        end

        define_method(:translation_key_pluralized_suffix_was) do
          underscore(self.name_was.pluralize)
        end

        define_method(:underscore) do |string|
          string.underscore.tr(' ', '_')
        end

      end
    end

  end
end

