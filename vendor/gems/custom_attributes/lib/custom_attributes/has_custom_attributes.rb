module CustomAttributes
  module HasCustomAttributes
    extend ActiveSupport::Concern

    included do
      attr_accessor :skip_custom_attribute_validation
    end

    module ClassMethods
      def has_custom_attributes(options = {})
        @options = options.reverse_merge(store_accessor_name: :properties)
        raise '(vendor/gems/custom_attributes) please provide mandaotry :target_id option' if @options[:target_id].nil?
        raise '(vendor/gems/custom_attributes) please provide mandaotry :target_type option' if @options[:target_type].nil?
        include CustomAttributes::Accessors
        validates_with CustomAttributes::Validator
        after_initialize :apply_custom_attributes

        define_method(:custom_attributes_names_types_hash) do
          custom_attributes.inject({}) do |hstore_attrs, attr_array|
            hstore_attrs[attr_array[0]] = attr_array[1].to_sym
            hstore_attrs
          end
        end

        define_method(:custom_attributes_names_default_values_hash) do
          custom_attributes.inject({}) do |hstore_attrs, attr_array|
            hstore_attrs[attr_array[0]] = attr_array[2]
            hstore_attrs
          end
        end

        define_method(:custom_attributes_set_default) do
          set_custom_defaults if self.respond_to?(:set_custom_defaults)
          custom_attributes_names_default_values_hash.each do |key, value|
            send(:"#{key}=", value) if send(key).nil?
          end
        end

        class_eval <<-RUBY, __FILE__, __LINE__+1

          define_method(:apply_custom_attributes) do
            set_custom_attributes(:#{@options[:store_accessor_name]})
            custom_attributes_set_default if self.new_record?
            self.assign_attributes(@custom_attributes_to_be_applied) if @custom_attributes_to_be_applied.present?
          end

          validate do
            CustomAttributes::CustomValidator.new(:#{@options[:store_accessor_name]}).validate(self)
            self.errors.add(:#{@options[:store_accessor_name]}, self.#{@options[:store_accessor_name]}.errors.full_messages.join(', ')) if self.#{@options[:store_accessor_name]}.errors.any?
          end

          def custom_attributes
            target_id = #{@options[:target_id]} || #{@options[:target_id].to_s.gsub('_id', '')}.try(:id)
            return [] if target_id.nil?
            CustomAttributes::CustomAttribute.get_from_cache(target_id, "#{@options[:target_type]}")
          end

          def initialize(*args)
            if args[0]
              @custom_attributes_to_be_applied = args[0].select { |k, v| ![:id, :#{@options[:target_id]}, :#{@options[:target_id].to_s.gsub('_id', '')}].include?(k.to_sym) }.with_indifferent_access
              args[0] = args[0].select { |k, v| [:id, :#{@options[:target_id]}, :#{@options[:target_id].to_s.gsub('_id', '')}].include?(k.to_sym) }.with_indifferent_access
            end
            super(*args)
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
            value = value.with_indifferent_access
            if self.new_record?
              hash = self.custom_attributes.inject({}.with_indifferent_access) do |h, cust_attr_array|
                h[cust_attr_array[#{CustomAttribute::NAME}]] = cust_attr_array[#{CustomAttribute::VALUE}]
                h
              end
              value.reverse_merge!(hash)
            end
            value.each do |k, v|
              if Array === v
                value[k] = v.join(',')
              end
            end
            super(value)
          end

          def self.clear_custom_attributes_cache
            CustomAttributes::CustomAttribute.clear_cache("#{@options[:target_type]}")
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
