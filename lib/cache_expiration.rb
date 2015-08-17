# Handles memory cache expiration. Class used by NeraMeMessageBus subscriber.
# At the moment we keep:
# * InstanceViewResolver cache storing paths and views for instance
# * Translations for instance
# * CustomAttributes
class CacheExpiration
  class << self

    def update_memory_cache
      if RedisCache.client.exists('cache_expiration')
        last_update = RedisCache.client.get("last_cache_update_#{current_worker_id}").to_f
        RedisCache.client.zrangebyscore('cache_expiration', "(#{last_update}", '+inf', with_scores: true).each do |value, score|
          handle_cache_expiration(value)
          RedisCache.client.set("last_cache_update_#{current_worker_id}", score)
        end
      end
    end

    def current_worker_id
      "#{ENV['HOSTNAME']}_#{Process.pid}"
    end

    def handle_cache_expiration(data)
      @data = JSON.parse(data).with_indifferent_access
      case @data[:cache_type]
      when 'InstanceView'
        expire_instance_view_cache
      when /Translation|Locale/
        expire_cache_for_translations
      when 'CustomAttribute'
        expire_cache_for_custom_attributes
      end
    end

    def expire_instance_view_cache
      InstanceViewResolver.instance.expire_cache_for_path(@data[:path], @data[:instance_id])
    end

    def expire_cache_for_translations
      I18N_DNM_BACKEND.update_cache(@data[:instance_id]) if defined? I18N_DNM_BACKEND
    end

    def expire_cache_for_custom_attributes
      CustomAttributes::CustomAttribute.clear_cache(@data[:target_type], @data[:instance_id])
    end
  end
end
