module ContentHoldersHelper

  def platform_context
    @platform_context_view ||= PlatformContext.current.decorate
  end

  def content_holder_cache_key(name)
    "theme.#{platform_context.theme.id}.content_holders.#{name}"
  end

  def inject_content_holder(name)
    Rails.cache.fetch content_holder_cache_key(name), expires_in: 12.hours do
      if content_holder = platform_context.content_holders.enabled.find_by_name(name)
        content_holder.content
      end
    end
  end

end