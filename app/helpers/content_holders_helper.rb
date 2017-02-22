# frozen_string_literal: true
module ContentHoldersHelper
  INJECT_PAGES = {
    'checkout#show' => 'checkout',
    'listings/reservations#review' => 'checkout',
    'dashboard/user_reservations#booking_successful' => 'checkout_success',
    'dashboard/orders#success' => 'checkout_success',
    'listings#show' => 'service/product_page',
    'search#index' => 'search_results'
  }.freeze

  def platform_context
    @platform_context_view ||= PlatformContext.current.decorate
  end

  def inject_pages_collection
    INJECT_PAGES.values.uniq.map do |path|
      [path.humanize, path]
    end + [['Any page', 'any_page']]
  end

  def content_holder_cache_key(name)
    "theme.#{platform_context.theme.id}.content_holders.names.#{name}"
  end

  def content_holder_for_path_cache_key(path = nil)
    "theme.#{platform_context.theme.id}.content_holders.paths.#{path}"
  end

  def inject_content_holder(name)
    if holder = get_content_holder(name)
        raw holder
    end
  end

  def get_content_holders_for_path(path)
    @get_content_holders_for_path_hash ||= {}
    @get_content_holders_for_path_hash[path] ||= platform_context.content_holders.enabled.by_inject_pages(path)
    @get_content_holders_for_path_hash[path]
  end

  def get_content_holder(name)
    Rails.cache.fetch content_holder_cache_key(name), expires_in: 12.hours do
      if content_holder = platform_context.content_holders.enabled.no_inject_pages.no_position(%w(meta head_bottom)).find_by(name: name)
        content_holder.content
      end
    end
  end
end
