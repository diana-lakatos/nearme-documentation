namespace :populate do
  desc "Populates locations with address components"
  task :locations => :environment do
    max_geocoding = 500
    current_geocoding = 0
    Location.find_each do |l|
      if current_geocoding >= max_geocoding
        puts "Max geocoding ( #{max_geocoding} ) reached, aborting!"
        exit
      end
      begin
        if l.formatted_address && !l.address_components
          results = Geocoder.search(l.formatted_address)
          current_geocoding += 1
          result = results.first
          if result
            wrapper_hash = {}
            result.address_components.each_with_index do |address_component_hash, index|
              wrapper_hash["#{index}"] = address_component_hash
            end
            hash = Location::AddressComponent::Parser.parse_geocoder_address_component_hash(wrapper_hash)
            l.address_components = hash
          puts "#{l.id}. Saved address components for \"#{l.formatted_address}\" \"#{l.address_components.inspect}\""
            l.save!
          end
        else
          puts "#{l.id}. Skipping, #{!l.formatted_address ? "no formatted address" : "already have address components"}"
        end
      rescue
        puts "#{l.id}. Something went wrong: #{$!.inspect}"
      end
    end
  end
end
