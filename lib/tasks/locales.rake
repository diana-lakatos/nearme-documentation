namespace :locales do
  desc 'Crates or updates the default (instance_id = nil) db locales from the yml files in source.'
  task create_or_update_defaults: :environment do
    Utils::EnLocalesSeeder.new.go!
  end
end
