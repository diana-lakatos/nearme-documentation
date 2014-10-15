module CustomAttributes
  class CustomAttribute::CacheTimestampsHolder

    @custom_attributes_cache_update_at = {}
    class << self
      attr_accessor :custom_attributes_cache_update_at

      def register_new_target_type(target_type)
        @custom_attributes_cache_update_at[target_type] ||= {}
      end

      def get(target_id, target_type)
        register_new_target_type(target_type)
        @custom_attributes_cache_update_at[target_type][target_id]
      end

      def touch(target_id, target_type)
        register_new_target_type(target_type)
        @custom_attributes_cache_update_at[target_type][target_id] = Time.zone.now.utc
      end

    end

  end
end

