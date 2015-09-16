module Metadata
  module UserMetadata
    extend ActiveSupport::Concern

    included do

      def populate_user_support_metadata!
        update_metadata({ support_metadata: build_support_metadata })
      end

      def build_support_metadata
        self.tickets.unscoped.user_metadata.collect{|t| {t.instance_id => t.count.to_i }}
      end

      def populate_listings_metadata!
        update_instance_metadata({
          has_draft_listings: listings.reload.draft.any?,
          has_draft_products: products.reload.draft.any?,
          has_any_active_listings: listings.reload.active.any?,
          has_any_active_products: products.reload.not_draft.any?
        }) if persisted?
      end

      def populate_instance_admins_metadata!
        if(instance_admin = instance_admins.first).present?
          update_instance_metadata({
            instance_admins_metadata: instance_admin.first_permission_have_access_to
          })
        end
      end

      def populate_companies_metadata!
        update_instance_metadata({
          companies_metadata: companies.reload.collect(&:id),
          has_draft_listings: listings.reload.draft.any?,
          has_draft_products: products.reload.draft.any?,
          has_any_active_listings: listings.reload.active.any?,
          has_any_active_products: products.reload.not_draft.any?
        })
      end

    end

  end
end
