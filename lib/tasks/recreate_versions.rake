namespace :recreate_versions do
  task create_optimized_version: :environment do
    Instance.find_each do |i|
      i.set_context!
      puts "Processing #{i.name}"
      # user last id -> 33249
      # photo last id -> 52240
      {
        Photo => ['image'],
        Theme => %w(logo_image hero_image logo_retina_image),
        UserBlogPost => %w(hero_image author_avatar_img)
      }.each do |klass, array_of_uploaders|
        puts "\t#{klass}"
        index = 0
        scope = klass.with_deleted.where(instance_id: i.id)
        total = scope.count
        scope.find_each do |object|
          index += 1
          puts "\t\t#{index}/#{total}" if (index % 10).zero?
          array_of_uploaders.each do |uploader|
            begin
              CarrierWave::SourceProcessing::Processor.new(object, uploader).generate_versions
            rescue => e
              puts "\t\t\tFailed to process #{object.id} - #{e}"
            end
          end
        end
      end
    end
  end

  desc 'Adds photo size to fit to event feed and link image medium'
  task add_new_photo_and_link_image_sizes_2016_05: :environment do
    5.times { puts }

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
