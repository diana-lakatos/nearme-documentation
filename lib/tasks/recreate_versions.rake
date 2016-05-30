namespace :recreate_versions do
  desc "Adds photo size to fit to event feed and link image medium"
  task add_new_photo_and_link_image_sizes_2016_05: :environment do
    5.times{puts}

    Instance.where(is_community: true).find_each do |i|
      i.set_context!
  
      Photo.find_each do |photo|
        photo.image.recreate_versions! rescue nil
        photo.skip_activity_feed_event = true
        photo.save(validate: false)
      end

      Link.find_each do |link|
        link.image.recreate_versions! rescue nil
        link.skip_activity_feed_event = true
        link.save(validate: false)
      end
    end
  end
end

