namespace :s3 do

  desc "Move files from old path to the new path"
  task :move => :environment do
    puts "Start..."
    AWS.config(access_key_id: 'AKIAI5EVP6HB47OZZXXA', secret_access_key: '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', region: 'us-west-1')
    s3 = AWS::S3.new
    @from_bucket = 'desksnearme.production'
    @to_bucket = 'nearme.production'
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
      objects = klass_string.constantize.unscoped.order('id ASC').find_each do |object|
        if "User" == klass_string || (Photo === object && object.listing.nil?) || (Theme === object && object.owner.nil?) || object.instance.nil?
          PlatformContext.current = nil
        else
          PlatformContext.current = PlatformContext.new(object.instance)
        end
        uploaders.each do |uploader|
          s3.buckets[@from_bucket].objects[object.send(uploader).legacy_store_dir].copy_to(object.send(uploader).store_dir, bucket_name: @to_bucket)
        end
      end
    end
  end

end
