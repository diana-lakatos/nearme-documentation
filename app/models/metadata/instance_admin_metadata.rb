module Metadata
  module InstanceAdminMetadata
    extend ActiveSupport::Concern

    included do
      after_commit :user_populate_instance_admins_metadata!
      delegate :populate_instance_admins_metadata!, to: :user, prefix: true, allow_nil: true
    end
  end
end
