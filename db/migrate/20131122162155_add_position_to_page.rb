class AddPositionToPage < ActiveRecord::Migration

  class Page < ActiveRecord::Base
  end

  class Theme < ActiveRecord::Base
    has_many :pages
  end

  def change
    add_column :pages, :position, :integer

    Theme.all.each do |theme|
      theme.pages.order('created_at ASC').each_with_index do |page, i|
        page.position = i
        page.save!
      end
    end
  end
end
