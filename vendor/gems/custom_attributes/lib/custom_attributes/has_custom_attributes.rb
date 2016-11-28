module CustomAttributes
  module HasCustomAttributes
    extend ActiveSupport::Concern

    included do
      attr_accessor :skip_custom_attribute_validation
    end

    module ClassMethods
      def has_custom_attributes(options = {})
        @options = options.reverse_merge(store_accessor_name: :properties)
        raise '(vendor/gems/custom_attributes) please provide mandatory :target_id option' if @options[:target_id].nil?
        raise '(vendor/gems/custom_attributes) please provide mandatory :target_type option' if @options[:target_type].nil?

        class_eval <<-RUBY, __FILE__, __LINE__ + 1

          def custom_attribute_target
            #{@options[:target_id].to_s.sub(/_id$/, '')}
          end

          def #{@options[:store_accessor_name]}_attributes=(attrs)
            attrs.each do |key, value|
              value = value.map(&:presence).compact if Array === value
              properties[key] = value
            end
          end

          def custom_attributes
            target_id = #{@options[:target_id]} || #{@options[:target_id].to_s.gsub('_id', '')}.try(:id)
            return [] if target_id.nil?
            CustomAttributes::CustomAttribute.get_from_cache(target_id, "#{@options[:target_type]}")
          end

          define_method(:#{@options[:store_accessor_name]}) do
            if read_attribute(:#{@options[:store_accessor_name]}).blank?
              hash = self.custom_attributes.inject({}.with_indifferent_access) do |h, cust_attr_array|
                h[cust_attr_array[#{CustomAttribute::NAME}]] = cust_attr_array[#{CustomAttribute::VALUE}]
                h
              end
              self.send(:#{@options[:store_accessor_name]}=, hash)
            end
            @custom_attributes_#{@options[:store_accessor_name]} ||= CustomAttributes::CollectionProxy.new(self, :#{@options[:store_accessor_name]})
            self.send(:#{@options[:store_accessor_name]}=, read_attribute(:#{@options[:store_accessor_name]}).with_indifferent_access)
            @custom_attributes_#{@options[:store_accessor_name]}.update_hash(read_attribute(:#{@options[:store_accessor_name]}))
            @custom_attributes_#{@options[:store_accessor_name]}
          end

          define_method(:#{@options[:store_accessor_name]}=) do |value|
            value = value.to_h if CustomAttributes::CollectionProxy === value
            value = (value.presence || {}).with_indifferent_access
            if self.new_record?
              hash = self.custom_attributes.inject({}.with_indifferent_access) do |h, cust_attr_array|
                h[cust_attr_array[#{CustomAttribute::NAME}]] = cust_attr_array[#{CustomAttribute::VALUE}]
                h
              end
              value.reverse_merge!(hash)
            end
            value.each do |k, v|
              if Array === v
                value[k] = v.map(&:presence).compact.join(',')
              end
            end
            set_keys = value.keys.map(&:to_s)
            self.custom_attributes.select { |ca| !set_keys.include?(ca[#{CustomAttribute::NAME}].to_s) }.each do |ca|
              value[ca[#{CustomAttribute::NAME}]] = ca[#{CustomAttribute::VALUE}]
            end
            custom_attribute_names = self.custom_attributes.map { |a| a[#{CustomAttribute::NAME}].to_s }
            value = value.reject { |custom_attribute_name, value| !custom_attribute_names.include?(custom_attribute_name.to_s) }

            super(value)
          end

          def self.public_custom_attributes_names(target_id)
            return [] if target_id.nil?
            CustomAttributes::CustomAttribute.get_from_cache(target_id, "#{@options[:target_type]}").map do |attr_array|
              if attr_array[#{CustomAttributes::CustomAttribute::PUBLIC}]
                if attr_array[#{CustomAttributes::CustomAttribute::ATTRIBUTE_TYPE}].to_sym == :array && #{CustomAttributes::CustomAttribute::MULTIPLE_ARRAY_TAGS}.include?(attr_array[#{CustomAttributes::CustomAttribute::HTML_TAG}].to_s)
                  { attr_array[#{CustomAttributes::CustomAttribute::NAME}] => [] }
                else
                  attr_array[#{CustomAttributes::CustomAttribute::NAME}]
                end
              else
                nil
              end
            end.compact
          end
        RUBY
      end
    end
  end
end
