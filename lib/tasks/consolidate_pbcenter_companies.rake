namespace :instance do

  desc "Consolidates all companies from instance PB Centers into one company"
  task :consolidate_pbcenter => :environment do
    instance = Instance.find_by_name('PB Centers')
    main_company = Company.where(:name => instance.name, :instance_id => instance.id).first
    unless main_company
      main_company = Company.create do |c|
        c.name = instance.name
        c.instance = instance
      end
    end
    instance.companies.each do |c|
      unless c.id == main_company.id
        main_company.industries += c.industries
        main_company.users += c.users
        main_company.creator = c.users.first unless main_company.creator
        c.locations.each do |l|
          l.company = main_company
          l.save!(:validate => false)
        end
        c.reload
        c.destroy
      end
    end
    main_company.industries = main_company.industries.uniq
    main_company.users = main_company.users.uniq
  end

end
