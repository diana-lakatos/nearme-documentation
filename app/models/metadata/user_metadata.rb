module Metadata
  module UserMetadata
    extend ActiveSupport::Concern

    included do

      def populate_listings_metadata!
        update_metadata({
          has_draft_listings: listings.reload.draft.any?,
          has_any_active_listings: listings.reload.active.any?
        })
      end

      def populate_instance_admins_metadata!
        update_metadata({
          instance_admins_metadata: build_instance_admins_metadata
        })
      end

      def build_instance_admins_metadata
        InstanceAdmin.unscoped.where(:user_id => self.id).all.inject({}) do |instance_admin_hash, instance_admin|
          instance_admin_hash[instance_admin.instance_id.to_s] = instance_admin.first_permission_have_access_to
          instance_admin_hash
        end
      end

      def populate_companies_metadata!
        update_metadata({
          companies_metadata: companies.reload.collect(&:id),
          has_draft_listings: listings.reload.draft.any?,
          has_any_active_listings: listings.reload.active.any?
        })
      end

    end

  end
end
