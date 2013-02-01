namespace :populate do

  desc "Populates locations with address components"
  task :locations => :environment do
    populator = Location::AddressComponentsPopulator.new
    begin
      Location.find_each do |l|
        populator.populate(l)
      end
      puts "Done."
    rescue
      puts "Populator failed: #{$!.inspect}"
    end
  end

end
