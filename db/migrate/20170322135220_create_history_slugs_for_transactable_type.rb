class CreateHistorySlugsForTransactableType < ActiveRecord::Migration
  def self.up
    # Some cleanup
    TransactableType.unscoped.where('type in (?)', ['Spree::ProductType', 'OfferType']).delete_all

    index = 0
    TransactableType.unscoped
                    .where('type is null or type = ?', 'TransactableType')
                    .where('slug is not null').find_each do |transactable_type|

      puts "At index: #{index + 1}" if (index % 1000).zero?
      index += 1

      existing = FriendlyId::Slug.where(slug: transactable_type.slug,
                                        sluggable: transactable_type,
                                        scope: "instance_id:#{transactable_type.instance_id}")
      if existing.blank?
        FriendlyId::Slug.create(slug: transactable_type.slug,
                                sluggable: transactable_type,
                                scope: "instance_id:#{transactable_type.instance_id}",
                                deleted_at: transactable_type.deleted_at)
      end
    end
  end

  def self.down
    # No need for self down (and it wouldn't be a good idea to possibly delete more than we created in self.up); also, on self.up
    # slugs will no longer be created if they exist
  end
end
