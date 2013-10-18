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
        main_company.payment_transfers += c.payment_transfers
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

  desc 'add adminsitrator for pb centers locations' 
  task :set_administrators => :environment do
    instance = Instance.find_by_name('PB Centers')
    instance.locations.each do |location|
      location.administrator_id = User.find_by_email(location.email).id
      location.save!(:validate => false)
    end
  end

  desc 'change all pb centers users passwords'
  task :set_all_pbcenters_users_password => :environment do
    instance = Instance.find_by_name('PB Centers')
    instance.companies.each do |company|
      company.users.each do |user|
        puts "Setting password for #{user.full_email}"
        user.password = user.password_confirmation = 'PBCd3sks'
        user.save!(:validate => false)
      end
    end
  end
end
