module Listing::RedundantDataSynchronizer
  extend ActiveSupport::Concern

  included do
    before_create :assign_foreign_keys

    def assign_foreign_keys
      self.instance_id ||= location.instance_id
      self.creator_id ||= location.creator_id
      self.administrator_id ||= location.administrator_id
    end
  end

end
