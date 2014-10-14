module CustomAttributes
  module HasCustomAttributes
    extend ActiveSupport::Concern

    included do
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
            set_custom_attributes(:#{@options[:store_accessor_name]}) unless @custom_attributes_set
            custom_attributes_set_default if self.new_record?
            self.assign_attributes(@custom_attributes_to_be_applied) if @custom_attributes_to_be_applied.present?
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

          def self.clear_custom_attributes_cache
            CustomAttributes::CustomAttribute.clear_cache("#{@options[:target_type]}")
          end

          def self.public_custom_attributes_names(target_id)
            return [] if target_id.nil?
            CustomAttributes::CustomAttribute.get_from_cache(target_id, "#{@options[:target_type]}").map do |attr_array|
              if attr_array[CustomAttributes::CustomAttribute::PUBLIC]
                if attr_array[CustomAttributes::CustomAttribute::ATTRIBUTE_TYPE].to_sym == :array
                  { attr_array[CustomAttributes::CustomAttribute::NAME] => [] }
                else
                  attr_array[CustomAttributes::CustomAttribute::NAME]
                end
              else
                nil
              end
            end
          end
        RUBY

      end
    end

  end
end
