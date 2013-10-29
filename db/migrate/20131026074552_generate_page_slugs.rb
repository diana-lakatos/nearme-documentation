class GeneratePageSlugs < ActiveRecord::Migration

  class Page < ActiveRecord::Base
    extend FriendlyId
    friendly_id :path, use: :slugged
  end

  def up
    Page.all.each do |page|
      page.slug = nil
      page.save!
    end
  end

  def down
  end
end
