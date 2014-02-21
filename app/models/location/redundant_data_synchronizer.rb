module Location::RedundantDataSynchronizer
  extend ActiveSupport::Concern

  included do
    before_create :assign_foreign_keys
    before_create :assign_listings_public

    before_save :assign_default_availability_rules
    after_update :update_children_administrator_id_key, :if => lambda { |location| location.administrator_id_changed? }

    def assign_foreign_keys
      self.instance_id ||= company.instance_id
      self.creator_id ||= company.creator_id
    end

    def update_children_administrator_id_key
      listings.reload.with_deleted.update_all(['administrator_id = ?', self.administrator_id])
      reservations.reload.update_all(['administrator_id = ?', self.administrator_id])
    end

    def assign_default_availability_rules
      if availability_rules.reject(&:marked_for_destruction?).empty?
        AvailabilityRule.default_template.apply(self)
      end
    end

    def assign_listings_public
      self.listings_public = company.try(:listings_public)
      nil
    end
  end

end
