module CustomAttributes
  module ActsAsCustomAttributesSet
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_custom_attributes_set(options = {})
        has_many :custom_attributes, as: :target, class_name: '::CustomAttributes::CustomAttribute'
      end
    end

  end
end
