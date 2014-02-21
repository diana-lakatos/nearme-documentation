module Company::RedundantDataSynchronizer
  extend ActiveSupport::Concern

  included do
    after_update :update_children_instance_id_key, :if => proc { |company| company.instance_id_changed? }
    after_update :update_children_creator_id_key, :if => proc { |company| company.creator_id_changed? }
    after_update :update_locations_listings_public, :if => proc { |company| company.listings_public_changed? }

    def update_children_instance_id_key
      locations.reload.with_deleted.update_all(['instance_id = ?', self.instance_id])
      listings.reload.with_deleted.update_all(['instance_id = ?', self.instance_id])
      reservations.reload.with_deleted.update_all(['instance_id = ?', self.instance_id])
    end

    def update_children_creator_id_key
      locations.reload.with_deleted.update_all(['creator_id = ?', self.creator_id])
      listings.reload.with_deleted.update_all(['creator_id = ?', self.creator_id])
      reservations.reload.with_deleted.update_all(['creator_id = ?', self.creator_id])
    end

    def update_locations_listings_public
      locations.reload.with_deleted.update_all(['listings_public = ?', self.listings_public])
    end
  end

end
