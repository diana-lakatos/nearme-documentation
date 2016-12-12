# Handles memory cache expiration. Class used by NeraMeMessageBus subscriber.
# At the moment we keep:
# * InstanceViewResolver cache storing paths and views for instance
# * Translations for instance
# * CustomAttributes
class CacheExpiration
  class << self
    def update_memory_cache
      return unless RedisCache.client.exists('cache_expiration')
      unique_commands = get_unique_commands
      unique_commands[:commands].each do |command|
        handle_cache_expiration(command)
      end
      RedisCache.client.set("last_cache_update_#{current_worker_id}", unique_commands[:last_score]) if unique_commands[:last_score]
    end

    def get_unique_commands
      unique_commands = []
      last_update = RedisCache.client.get("last_cache_update_#{current_worker_id}").to_f
      all_commands = RedisCache.client.zrangebyscore('cache_expiration', "(#{last_update}", '+inf', with_scores: true)
      all_commands.each do |value, score|
        data = JSON.parse(value).with_indifferent_access
        data.delete(:timestamp)
        unless unique_commands.include?(data)
          unique_commands << data
        end
      end
      { commands: unique_commands, last_score: all_commands.last.try(:last) }
    end

    def rebuild_cache_for_new_worker
      update_memory_cache
    end

    def current_worker_id
      "#{ENV['HOSTNAME']}_#{Process.ppid}_#{Process.pid}"
    end

    def handle_cache_expiration(data)
      @data = data.is_a?(String) ? JSON.parse(data).with_indifferent_access : data
      case @data[:cache_type]
        when 'InstanceView'
          expire_instance_view_cache
        when /Translation|Locale/
          expire_cache_for_translations
        when 'CustomAttribute'
          expire_cache_for_custom_attributes
        when 'RebuildInstanceView'
          rebuild_cache_for_instance_views
        when 'RebuildTranslations'
          rebuild_cache_for_translations
        when 'RebuildCustomAttributes'
          rebuild_cache_for_custom_attributes
      end
    end

    def expire_instance_view_cache
      InstanceViewResolver.instance.expire_cache_for_path(@data[:path], @data[:instance_id])
    end

    def expire_cache_for_translations
      I18N_DNM_BACKEND.update_cache(@data[:instance_id], @data[:with_defaults]) if defined? I18N_DNM_BACKEND
    end

    def expire_cache_for_custom_attributes
      CustomAttributes::CustomAttribute.clear_cache(@data[:target_type], @data[:target_id])
    end

    def rebuild_cache_for_translations
      I18N_DNM_BACKEND.rebuild!
    end

    def rebuild_cache_for_instance_views
      InstanceViewResolver.instance.clear_cache
    end

    def rebuild_cache_for_custom_attributes
      ::CustomAttributes::CustomAttribute::CacheDataHolder.clear_all_cache!
    end

    def send_expire_command(rebuild_type, options = {})
      opts = { cache_type: rebuild_type, timestamp: Time.now.to_f }.merge(options)
      RedisCache.client.zadd 'cache_expiration', Time.now.to_f, opts.to_json
    end
  end
end
