class CopyLegalPageToRentSalonSpace < ActiveRecord::Migration

  class Page < ActiveRecord::Base
  end

  class Instance < ActiveRecord::Base
    DEFAULT_INSTANCE_NAME = 'DesksNearMe'

    def self.default_instance
      self.find_by_name(DEFAULT_INSTANCE_NAME)
    end
  end

  class Theme < ActiveRecord::Base
    has_many :pages
  end

  class Domain < ActiveRecord::Base
    belongs_to :target, :polymorphic => true
  end

  def up
    rent_salon_space_domain = Domain.where('name like ?', 'rent-salon-space.desksnear.me').first
    rent_salon_space_instance = rent_salon_space_domain.try(:target) 
    rent_salon_space_theme = Theme.where('owner_id = ? AND owner_type = ?', rent_salon_space_instance.try(:id), 'Instance').first 

    dnm_instance = Instance.default_instance
    dnm_theme = Theme.where('owner_id = ? AND owner_type = ?', dnm_instance.try(:id), 'Instance').first
    dnm_legal_page = dnm_theme.pages.where('path like ?', 'Legal').first

    if rent_salon_space_theme && dnm_legal_page && !rent_salon_space_theme.pages.where(path: 'Legal').any?
      rent_salon_space_legal_page = rent_salon_space_theme.pages.new({
        content: dnm_legal_page.content,
        path: dnm_legal_page.path,
        slug: dnm_legal_page.slug,
        position: 0
      }) 

      rent_salon_space_legal_page.save!
    end
  end

  def down
  end
end
