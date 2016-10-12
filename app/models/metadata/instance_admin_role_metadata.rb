module Metadata
  module InstanceAdminRoleMetadata
    extend ActiveSupport::Concern

    included do
      after_commit :populate_instance_admins_metadata!, if: ->(iar) { iar.should_populate_metadata? }

      def populate_instance_admins_metadata!
        instance_admins.reload.each(&:user_populate_instance_admins_metadata!)
      end

      def should_populate_metadata?
        # we are interested only in attributes that either became first_permission or stopped being first_permission
        return true if first_permission_have_access_to.nil?
        self.class::PERMISSIONS[0..self.class::PERMISSIONS.index(first_permission_have_access_to.capitalize)].any? do |permission|
          metadata_relevant_attribute_changed?("permission_#{permission.downcase}")
        end
      end
    end
  end
end
