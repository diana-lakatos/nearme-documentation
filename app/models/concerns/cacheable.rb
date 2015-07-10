module Cacheable
  extend ActiveSupport::Concern

  included do    
    after_save :update_instance_cache_key
    after_destroy :update_instance_cache_key

    def update_instance_cache_key
      if instance
        instance.fast_recalculate_cache_key!
      end
    end
  end
end