module CustomAttributes
  class CustomAttribute::CacheDataHolder

    @custom_attributes_as_array = {}
    class << self

      attr_accessor :custom_attributes_as_array

      def register_new_target_type(target_type)
        @custom_attributes_as_array[target_type] ||= {}
      end

      def fetch(target_id, target_type, &block)
        if !(data = get(target_id, target_type)).nil?
         data
        else
          store(target_id, target_type, yield)
        end
      end

      def get(target_id, target_type)
        register_new_target_type(target_type)
        @custom_attributes_as_array[target_type][target_id]
      end

      def store(target_id, target_type, data)
        register_new_target_type(target_type)
        @custom_attributes_as_array[target_type][target_id] = data
      end

      def destroy(target_id, target_type)
        register_new_target_type(target_type)
        @custom_attributes_as_array[target_type][target_id] = nil
      end

      def clear_all_cache!
        @custom_attributes_as_array = {}
      end

    end
  end
end

