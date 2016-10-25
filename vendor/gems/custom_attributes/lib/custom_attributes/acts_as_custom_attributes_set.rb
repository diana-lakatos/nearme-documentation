module CustomAttributes
  module ActsAsCustomAttributesSet
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_custom_attributes_set(options = {})
        options = options.merge(as: :target, class_name: '::CustomAttributes::CustomAttribute').reverse_merge(dependent: :destroy)
        has_many :custom_attributes, options

        define_method(:cached_custom_attributes) do
          CustomAttributes::CustomAttribute.get_from_cache(id, self.class.name)
        end
      end
    end
  end
end
