# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class InstanceProfileTypeConverter < BaseConverter
      primary_key :name
      properties :name, :profile_type, :admin_approval,
                 :create_company_on_sign_up, :onboarding, :search_only_enabled_profiles

      convert :validation, using: CustomValidationConverter
      convert :custom_attributes, using: CustomAttributeConverter
      convert :form_components, using: FormComponentConverter

      def scope
        @model.instance_profile_types
      end
    end
  end
end
