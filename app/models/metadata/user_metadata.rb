module Metadata
  module UserMetadata
    extend ActiveSupport::Concern

    included do
      def populate_user_support_metadata!
        update_metadata(support_metadata: build_support_metadata)
      end

      def build_support_metadata
        tickets.unscoped.user_metadata.collect { |t| { t.instance_id => t.count.to_i } }
      end

      def populate_instance_admins_metadata!
        if (instance_admin = instance_admins.first).present?
          update_instance_metadata(instance_admins_metadata: instance_admin.first_permission_have_access_to)
        else
          update_instance_metadata(instance_admins_metadata: nil)
        end
      end

      def populate_companies_metadata!
        update_instance_metadata(companies_metadata: companies.reload.collect(&:id))
      end
    end
  end
end
