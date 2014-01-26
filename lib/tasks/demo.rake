namespace :demo do
  ### DesksNearMe
  namespace :desksnearme do
    namespace :db do

      desc "Load all social connections for info@desksnear.me user in San Francisco"
      task :connections_in_sf => [:environment] do
        @me = User.find_by_email('info@desksnear.me') || FactoryGirl.create(:user, email: 'info@desksnear.me')
        @listing = FactoryGirl.create(:listing, location: FactoryGirl.build(:location_in_san_francisco, address: 'Golden Gate Bridge'))

        # 3 friends visited listing
        3.times { |i| @me.add_friend(FactoryGirl.create(:user, name: "Jimmy Visitor #{i}", email: "test-social-#{i}@example.com")) }
        @me.friends.first(3).each {|f| FactoryGirl.create(:past_reservation, state: 'confirmed', listing: @listing, user:f)}

        # 1 friend is host of listing
        host = FactoryGirl.create(:user, name: "Jimmy Host", email: "test-social-host@example.com")
        @me.add_friend(host)
        @listing.location.update_attribute(:administrator_id, host.id)

        # 2 friends know host of listing
        know_host = []
        2.times { |i|
          know_host << FactoryGirl.create(:user, name: "Jimmy Host's Friend #{i}", email: "test-social-hosts-friend-#{i}@example.com")
          @me.add_friend(know_host.last)
        }
        know_host.each {|f| f.add_friend(host)}

        # 1 mutual friend worked here
        mutual_friend = FactoryGirl.create(:user, name: 'Jimmy\'s mutual friend')
        @me.friends.first.add_friend(mutual_friend)
        FactoryGirl.create(:past_reservation, state: 'confirmed', listing: @listing, user:mutual_friend)
      end


      desc "Create second instance for info@desksnear.me user"
      task :second_instance => [:environment] do
        instance = FactoryGirl.create(:instance, name: 'Custom instance')
        user = User.find_by_email('info@desksnear.me') || FactoryGirl.create(:user, email: 'info@desksnear.me')
        instance_owner = FactoryGirl.create(:instance_admin, :user_id => user.id, :instance_id => instance.id)
        instance.domains.create(name: ENV['DOMAIN'] || 'instance.dev')
      end

      desc "Create database with demo data"
      task :setup => ["db:create", "db:schema:load", :environment, "demo:desksnearme:db:seed"]

      desc "Seed demo data"
      task :seed => :environment do
        Utils::DesksnearmeDemoDataSeeder.new.go!
      end
    end
  end

  ### RVnow
  namespace :rvnow do
    namespace :db do

      desc "Create database with demo data"
      task :setup => ["db:create", "db:schema:load", :environment, "demo:rvnow:db:seed"]

      desc "Seed demo data"
      task :seed => :environment do
        Utils::RvnowDemoDataSeeder.new.go!
      end
    end
  end
end
