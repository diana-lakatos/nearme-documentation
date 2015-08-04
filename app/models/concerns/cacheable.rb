# concern used for expiring memory cache
# to pass custom options to MessageBus from certain model override expire_cache_options method
module Cacheable
  extend ActiveSupport::Concern

  included do
    attr_accessor :skip_expire_cache
    after_commit :expire_cache_key, unless: -> (translation) { translation.skip_expire_cache }

    def expire_cache_key(opts = expire_cache_options)
      instance.fast_recalculate_cache_key! if instance && instance.respond_to?(:context_cache_key)
      NearMeMessageBus.publish '/cache_expiration', {cache_type: self.class.name.demodulize}.merge(opts)
    end

    def expire_cache_options
      {}
    end
  end
end
