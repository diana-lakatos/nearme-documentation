desc "Move files from filepicker to s3"
task from_filepicker_to_s3: :environment do
  Instance.find_each do |instance|
    PlatformContext.current = PlatformContext.new(instance)
    {
      Photo => :image, Spree::Image => :image, User => :avatar, Theme => :icon_image, Theme => :icon_retina_image,
      Theme => :favicon_image, Theme => :logo_image, Theme => :logo_retina_image, Theme => :hero_image
    }.each do |klass, column|
        klass.where("#{column}_original_url LIKE '%filepicker.io%'").find_each do |object|
          object.send("remote_#{column}_url=", object.send("#{column}_original_url"))
          object.save!
          puts "#{klass.name}##{object.id} processed"
        end
      end
  end
  PlatformContext.current = nil
end
