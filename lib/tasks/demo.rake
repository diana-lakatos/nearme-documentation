namespace :demo do

  namespace :db do

    desc "Create database with demo data"
    task :setup => ["db:create", "db:schema:load", :environment, "demo:db:seed"]

    desc "Seed demo data"
    task :seed => :environment do
      Utils::DemoDataSeeder.new.go!
    end

  end 

end
