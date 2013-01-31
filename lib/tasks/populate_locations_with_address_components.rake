namespace :populate do

  desc "Populates locations with address components"
  task :locations => :environment do
    populator = Location::AddressComponentsPopulator.new
    begin
      Location.find_each do |l|
        populator.populate(l)
      end
    rescue
      puts "Populator was terminated: #{$!.inspect}"
    end
    puts "All locations are populated."
  end

end
