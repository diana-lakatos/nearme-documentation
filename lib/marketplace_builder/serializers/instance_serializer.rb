module MarketplaceBuilder
  module Serializers
    class InstanceSerializer < BaseSerializer
      resource_name -> (i) { 'instance_attributes' }

      properties :name, :is_community, :require_verified_user, :bookable_noun, :wish_lists_enabled, :enable_reply_button_on_host_reservations,
        :force_accepting_tos, :default_country, :default_currency, :skip_company, :split_registration, :hidden_ui_controls
    end
  end
end
