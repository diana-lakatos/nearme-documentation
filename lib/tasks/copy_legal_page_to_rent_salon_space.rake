namespace :copy_legal_page_to_rent_salon_space do

  desc "Copy legal page from DNM instance into rent_salon_space instance"
  task :start => :environment do
    rent_salon_space_domain = Domain.where('name like ?', 'rent-salon-space.desksnear.me').first
    rent_salon_space_instance = rent_salon_space_domain.try(:target) 
    rent_salon_space_theme = rent_salon_space_instance.try(:theme) 

    dnm_instance = Instance.default_instance
    dnm_theme = dnm_instance.try(:theme)
    dnm_legal_page = dnm_theme.present? ? dnm_theme.pages.where('path like ?', 'Legal').first : nil

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
end
