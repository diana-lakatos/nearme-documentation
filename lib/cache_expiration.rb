# Handles memory cache expiration. Class used by NeraMeMessageBus subscriber.
# At the moment we keep:
# * InstanceViewResolver cache storing paths and views for instance
# * Translations for instance
# * CustomAttributes
class CacheExpiration
  class << self
    def handle_cache_expiration(msg)
      case msg.data[:cache_type]
      when 'InstanceView'
        expire_instance_view_cache(msg.data[:args][:path], msg.data[:instance_id])
      when /Translation|Locale/
        expire_cache_for_translations(msg.data[:instance_id])
      when 'CustomAttribute'
        expire_cache_for_custom_attributes(msg.data[:args][:target_type])
      else
        raise NotImplementedError
      end
    end

    def expire_instance_view_cache(path, instance_id)
      InstanceViewResolver.instance.expire_cache_for_path(path, instance_id)
    end

    def expire_cache_for_translations(instance_id)
      I18N_DNM_BACKEND.update_cache(instance_id) if defined? I18N_DNM_BACKEND
    end

    def expire_cache_for_custom_attributes(target)
      CustomAttributes::CustomAttribute.clear_cache(target)
    end
  end
end
