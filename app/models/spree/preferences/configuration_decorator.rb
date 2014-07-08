Spree::Preferences::Configuration.class_eval do
  def preference_cache_key(name)
    [rails_cache_id, PlatformContext.current.try(:instance).try(:id), self.class.name, name].compact.join('::').underscore
  end
end
