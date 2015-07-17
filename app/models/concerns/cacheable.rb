# concern used for expiring memory cache
# to pass custom options to MessageBus from certain model override expire_cache_options method
module Cacheable
  extend ActiveSupport::Concern

  included do
    after_commit :expire_cache_key

    def expire_cache_key
      instance.fast_recalculate_cache_key! if instance && instance.respond_to?(:context_cache_key)
      NearMeMessageBus.publish '/cache_expiration', {cache_type: self.class.name.demodulize}.merge(expire_cache_options)
    end

    def expire_cache_options
      {}
    end
  end
end
