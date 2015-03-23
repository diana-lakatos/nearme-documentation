desc "Move files from filepicker to s3"
task from_filepicker_to_s3: :environment do
  Instance.find_each do |instance|
    puts "Processing instance #{instance.id}"
    PlatformContext.current = PlatformContext.new(instance)
    {
      Photo => :image, Spree::Image => :image, User => :avatar, Theme => :icon_image, Theme => :icon_retina_image,
      Theme => :favicon_image, Theme => :logo_image, Theme => :logo_retina_image, Theme => :hero_image
    }.each do |klass, column|
        klass.where("#{column}_original_url LIKE '%filepicker.io%'").find_each do |object|
          if object.send(column).current_url =~ /filepicker/ || !all_versions_exist?(object, column)
            begin
              object.send("remote_#{column}_url=", object.send("#{column}_original_url"))
              object.save!
              object.update_column "#{column}_original_url", object.attributes["#{column}_original_url"].sub('filepicker.io', 'filepicker-processed')
              puts "#{klass.name}##{object.id} processed"
            rescue
              puts "Failed to process #{klass.name}##{object.id}, probably #{column}_original url doesn't exist"
            end
          end
        end
      end
  end
  PlatformContext.current = nil
end

def all_versions_exist?(object, column)
  version_exists?(object, column)
  object.send(column).versions.keys.all? do |version|
    version_exists?(object, column, version)
  end
end

def version_exists?(object, column, version = nil)
  uri = URI(version ? object.send(column).send(version).url : object.send(column).url)
  Net::HTTP.new(uri.host).request_head(uri.path).code.to_i == 200
end
