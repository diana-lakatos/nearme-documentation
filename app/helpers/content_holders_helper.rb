module ContentHoldersHelper

  def platform_context
    @platform_context_view ||= PlatformContext.current.decorate
  end

  def inject_pages_collection
    ContentHolder::INJECT_PAGES.values.uniq.map do |path|
      [path.humanize, path]
    end + [['Any page', 'any_page']]
  end

  def content_holder_cache_key(name)
    "theme.#{platform_context.theme.id}.content_holders.names.#{name}"
  end

  def content_holder_for_path_cache_key
    "theme.#{platform_context.theme.id}.content_holders.paths.#{controller_path}##{action_name}"
  end

  def inject_content_holder(name)
    if holder = get_content_holder(name)
      raw holder
    end
  end

  def get_content_holders_for_path(path)
    platform_context.content_holders.enabled.by_inject_pages(path)
  end

  def get_content_holder(name)
    Rails.cache.fetch content_holder_cache_key(name), expires_in: 12.hours do
      if content_holder = platform_context.content_holders.enabled.find_by_name(name)
        content_holder.content
      end
    end
  end

end
