namespace :reprocess do
  desc "Reprocess all of the instance's themes"
  task :css => :environment do
    Theme.find_each do |i|
      begin
        i.recompile_theme
        puts "Reprocessed Instance Theme ##{i.id} CSS successfully"
      rescue
        puts "Reprocessing Instance Theme ##{i.id} CSS failed: #{$!.inspect}"
      end
    end
  end
  
  desc "Reprocess all the photos"
  task :photos => :environment do
    Photo.find_each do |p|
      begin
        p.image.recreate_versions!
        puts "Reprocessed Photo##{p.id} successfully"
      rescue
        puts "Reprocessing Photo##{p.id} failed: #{$!.inspect}"
      end
    end
  end

  desc "Refetch avatars from facebook"
  task :refetch_avatars_from_facebook => :environment do
    users = User.joins(:authentications).where("authentications.provider" => "facebook")
    users = users.where('avatar IS NOT NULL').readonly(false)
    users = users.select{|u| u.avatar.file && u.avatar.file.size < 10000 rescue nil}.compact

    users.each do |user|
      begin
        authentication = user.authentications.detect{|a| a.provider == 'facebook'}
        url = "http://graph.facebook.com/#{authentication.uid}/picture?width=500"
        puts "Processing User##{user.id} from url: #{url}"
        user.update_column(:avatar_original_url, url)
        user.reload
        CarrierWave::SourceProcessing::Processor.new(user, 'avatar').generate_versions
        user.update_column(:avatar_original_url, nil)
        puts "Reprocessed User##{user.id} successfully"
      rescue
        puts "Reprocessing User##{user.id} failed: #{$!.inspect}"
      end
    end
  end

  desc 'Refetch address_components'
  task :refetch_address_components => :environment do
    locations = Location.all.select{|location| location.address_components.blank? }
    locations.each do |location|
      geocoded = Geocoder.search(location.address).try(:first)
      geocoded ||= Geocoder.search("#{location.latitude}, #{location.longitude}").try(:first) if location.latitude && location.longitude

      if geocoded
        populator = Location::AddressComponentsPopulator.new
        populator.set_result(geocoded)
        location.address_components = populator.wrap_result_address_components
        puts "Fetched address_components for ##{location.id}: #{location.address_components.inspect}"
        if location.save
          puts "###### and saved successfuly" 
        else
          puts "###### but couldn't save: #{location.errors.full_messages.inspect}"
        end
        puts ""
      else
        puts "Couldn't get address_components for ##{location.id} with address #{location.address} and coordinates #{location.latitude}, #{location.longitude}"
        puts ""
      end
    end
  end

end
