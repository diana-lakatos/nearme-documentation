class AddHistorySlugsForExistingUsers < ActiveRecord::Migration
  def self.up
    index = 0
    User.with_deleted.find_each do |user|
      index += 1
      puts "At index: #{index}" if index % 1000 == 0
      existing = FriendlyId::Slug.where(slug: user.slug, sluggable: user, scope: "instance_id:#{user.instance_id}")
      if existing.blank?
        FriendlyId::Slug.create(slug: user.slug, sluggable: user, scope: "instance_id:#{user.instance_id}", deleted_at: user.deleted_at)
      end
    end
  end

  def self.down
    # No need for self down (and it wouldn't be a good idea to possibly delete more than we created in self.up); also, on self.up
    # slugs will no longer be created if they exist
  end
end
