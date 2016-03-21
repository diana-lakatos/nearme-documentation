desc "Adds fullscreen version to all transactables and projects"
task add_fullscreen_size: :environment do

  5.times{puts}
  puts "Creating fullscreen photo version"

  Instance.find_each do |i|
    i.set_context!
    puts "Processing #{i.name}..."

    Location.find_each do |location|
      location.listings.find_each do |transactable|
        transactable.skip_metadata = true
        transactable.photos.find_each do |photo|
          photo.skip_metadata = true
          photo.force_regenerate_versions = true
          photo.save(validate: false) rescue nil
        end
        transactable.update_metadata({ photos_metadata: transactable.build_photos_metadata_array })
      end

      location.populate_photos_metadata!
    end
  end
end
