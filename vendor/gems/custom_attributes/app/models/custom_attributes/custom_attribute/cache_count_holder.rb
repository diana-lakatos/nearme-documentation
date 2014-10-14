module CustomAttributes
  class CustomAttribute::CacheCountHolder

    @custom_attributes_count_array = {}
    class << self

      attr_accessor :custom_attributes_count_array

      def register_new_target_type(target_type)
        @custom_attributes_count_array[target_type] ||= {}
      end

      def get(target_id, target_type)
        register_new_target_type(target_type)
        @custom_attributes_count_array[target_type][target_id]
      end

      def store(target_id, target_type, count)
        register_new_target_type(target_type)
        @custom_attributes_count_array[target_type][target_id] = count
      end
    end
  end
end

