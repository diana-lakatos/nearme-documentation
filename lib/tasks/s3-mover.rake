namespace :s3 do

  desc "Move files from old path to the new path"
  task :move => :environment do
    puts "Start..."
    @from_bucket = 'desksnearme.production'
    @last_invoked_at = Time.zone.local(2014,7,8,0,0)

    PlatformContext.current = nil
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
      "User" => [:avatar],
    }.each do |klass_string, uploaders|
      puts "=== #{klass_string} ==="
      klass_string.constantize.unscoped.order('id DESC').find_each do |object|
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
