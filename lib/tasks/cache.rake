namespace :cache do
  desc 'rebuild translations cache for all instances'
  task rebuild_translations: :environment do
    CacheExpiration.send_expire_command 'RebuildTranslations'
  end

  desc 'rebuild Instance Views cache for all instances'
  task rebuild_instance_views: :environment do
    CacheExpiration.send_expire_command 'RebuildInstanceView'
  end

  desc 'rebuild Custom Attributes cache for all instances'
  task rebuild_custom_attributes: :environment do
    CacheExpiration.send_expire_command 'RebuildCustomAttributes'
  end

  desc 'rebuild all in-memory cache for all instances'
  task rebuild_all_cache: :environment do
    CacheExpiration.send_expire_command 'RebuildTranslations'
    CacheExpiration.send_expire_command 'RebuildInstanceView'
    CacheExpiration.send_expire_command 'RebuildCustomAttributes'
  end
end
