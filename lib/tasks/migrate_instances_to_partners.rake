namespace :migrate_instance_to_partners do
  desc "Migrate certain instances to partners"
  task :start => :environment do
    puts 'Migrating instances to partners under dnm instance...'

    INSTANCES = { 'San Jose Sillicon Valley Chamber of Commerce' => 'no_scoping',
                  'San Francisco Chamber of Commerce'            => 'no_scoping',
                  'Ramada Encore Geneva'                         => 'no_scoping',
                  'W Hotels L.A. Westwood'                       => 'all_associated_listings',
                  'PB Centers'                                   => 'all_associated_listings',
                  'Rent Salon Space'                             => 'all_associated_listings',
                  'Dutchess County Regional Chamber of Commerce' => 'no_scoping'
                }

    dnm_instance = Instance.find_by_name('DesksNearMe')

    begin
      Partner.transaction do
        INSTANCES.each do |name, search_scope|

          # Create a new parter to replace the old instance
          puts "instance: #{name}"
          old_instance = Instance.find_by_name(name)
          partner = dnm_instance.partners.build(name: name, search_scope_option: search_scope)
          partner.save!

          # Associate the instance's companies to the new partner
          puts " companies:"
          old_instance.companies.each do |company|
            puts "  #{company.name}"
            # Use update_columns to skip callbacks and validations
            company.update_column(:partner_id, partner.id)
            company.update_column(:instance_id, dnm_instance.id)
          end

          # Associate the instance's domains to the new partner
          puts " domains:"
          old_instance.domains.each do |domain|
            puts "  #{domain.name}"
            domain.target = partner
            domain.save!
          end

          # Associate theme from old_instance to partner
          puts " theme:"
          theme = old_instance.theme
          puts "  #{theme.name}"
          # Use update_columns to prevent theme recompliation callback from triggering
          theme.update_column(:owner_type, "Partner")
          theme.update_column(:owner_id, partner.id)

          # Delete the old instance
          old_instance.delete
        end
      end
    rescue => e
      puts 'Aborting migration, transaction failed:'
      puts e
    end

  end
end
