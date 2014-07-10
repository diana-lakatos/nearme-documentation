namespace :s3 do

  desc "Move files from old path to the new path"
  task :move => :environment do
    puts "Start..."
    @from_bucket = 'desksnearme.production'
    @last_invoked_at = Time.zone.local(2014,7,8,0,0)

    @to_bucket = if Rails.env.staging?
                   puts "Staging env"
                   'near-me.staging'
                 elsif Rails.env.production?
                   puts "Production env"
                   'near-me.production'
                 else
                   puts "development? - doing for production env"
                   'near-me.production'
                 end
    {
      "BlogPost" => [:header, :author_avatar],
      "ThemeFont" => [
        :bold_eot, :bold_svg, :bold_ttf, :bold_woff, :medium_eot,
        :medium_svg, :medium_ttf, :medium_woff, :regular_eot, :regular_svg,
        :regular_ttf, :regular_woff
      ],
      "Ckeditor::AttachmentFile" => [:data],
      "Ckeditor::Picture" => [:data],
      "BlogInstance" => [:header, :header_logo, :header_icon ],
      "User" => [:avatar],
      "Photo" => [:image],
      "Page" => [:hero_image],
      "Theme" => [:icon_image, :icon_retina_image, :favicon_image, :logo_image, :logo_retina_image, :hero_image, :compiled_stylesheet]
    }.each do |klass_string, uploaders|
      PlatformContext.current = nil
      puts "=== #{klass_string} ==="
      klass_string.constantize.unscoped.where('updated_at > ?', @last_invoked_at).order('id ASC').find_each do |object|
        if object.instance.nil?
          if "BlogPost" == klass_string
            puts "No instance for BlogPost, assuming DesksNearMe"
            PlatformContext.current = PlatformContext.new(Instance.default_instance)
          else
            puts "#{object.class}(id=#{object.id}) skipped - lack of instance"
            next
          end
        elsif "User" == klass_string
          PlatformContext.current = nil
        else
          PlatformContext.current = PlatformContext.new(object.instance)
        end
        puts "#{klass_string} id=#{object.id} (#{object.updated_at})"
        uploaders.each do |uploader|
          legacy_store_dir = object.send(uploader).legacy_store_dir
          legacy_store_dir += "/" unless legacy_store_dir.last == '/'
          store_dir = object.send(uploader).store_dir
          store_dir = store_dir[0..(store_dir.length-2)] if store_dir.last == '/'
          cmd = "s3cmd cp -r s3://#{@from_bucket}/#{legacy_store_dir} s3://#{@to_bucket}/#{object.send(uploader).store_dir} 2>&1"
          if @to_bucket
            result = `#{cmd}`
            puts "#{klass_string} id=#{object.id} has not been copied!" if result.blank?
            puts result if result.present?
          else
            puts cmd
          end
        end
      end
    end
  end

end
