module Reservation::RedundantDataSynchronizer
  extend ActiveSupport::Concern

  included do
    before_create :assign_foreign_keys

    def assign_foreign_keys
      self.instance_id ||= listing.instance_id
      self.creator_id ||= listing.creator_id
      self.administrator_id ||= listing.administrator_id
    end
  end

end
