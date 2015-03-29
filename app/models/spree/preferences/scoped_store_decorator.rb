Spree::Preferences::ScopedStore.class_eval do
  private
  def key_for(key)
    [rails_cache_id, PlatformContext.current.try(:instance).try(:id), @prefix, key, @suffix].compact.join('/')
  end
end
