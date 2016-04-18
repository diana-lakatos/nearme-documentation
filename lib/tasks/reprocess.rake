namespace :reprocess do
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

  desc "Regenerate all relationships"
  task :relationships => :environment do
    UserRelationship.with_deleted.delete_all
    Authentication.select(:id).find_each do |authentication|
      FindFriendsJob.perform(authentication.id)
    end
  end

  desc "Regenerate all slugs where we use friendly_id"
  task :slugs => :environment do
    # Store current slugs in history
    puts "Saving Location slugs in history"
    Location.order('created_at ASC').each do |obj|
      old_slug = obj.slug
      if obj.send(:set_slug) != old_slug
        FriendlyId::Slug.create(slug: old_slug.strip, sluggable_id: obj.id, sluggable_type: 'Location')
      end
    end

    [Location, Page, User].each do |model|
      puts '#'*80
      puts "Processing #{model}"
      updated_objects = 0

      model.order('created_at ASC').each do |obj|
        begin
          old_slug = obj.slug
          unless obj.save
            obj.send(:set_slug)
            obj.save(validate: false)
          end
          if old_slug != obj.reload.slug
            updated_objects += 1
            puts "#{model}##{obj.id}: #{old_slug} -> #{obj.slug}"
          end
        rescue
          puts "Reprocessing #{model}##{obj.id} failed: #{$!.inspect}"
        end
      end

      puts "Regenerated #{updated_objects} slugs successfully."
      puts
    end
  end

end
