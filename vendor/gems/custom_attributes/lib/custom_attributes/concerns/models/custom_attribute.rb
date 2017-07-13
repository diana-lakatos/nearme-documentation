# frozen_string_literal: true
module CustomAttributes
  module Concerns
    module Models
      module CustomAttribute
        extend ActiveSupport::Concern
        include ::CustomAttributes::Concerns::Models::Castable

        included do
          attr_accessor :required, :max_length, :min_length

          self.table_name = 'custom_attributes'

          NAME = 0 unless defined?(NAME)
          ATTRIBUTE_TYPE = 1 unless defined?(ATTRIBUTE_TYPE)
          VALUE = 2 unless defined?(VALUE)
          PUBLIC = 3 unless defined?(PUBLIC)

          VALID_VALUES = 4 unless defined?(VALID_VALUES)
          HTML_TAG = 5 unless defined?(HTML_TAG)
          SEARCHABLE = 6 unless defined?(SEARCHABLE)
          SEARCH_IN_QUERY = 7 unless defined?(SEARCH_IN_QUERY)

          ATTRIBUTE_TYPES = %w(array string integer float decimal datetime time date binary boolean photo file).freeze unless defined?(ATTRIBUTE_TYPES)
          HTML_TAGS = %w(input select switch textarea check_box radio_buttons check_box_list range hidden).freeze unless defined?(HTML_TAGS)
          MULTIPLE_ARRAY_TAGS = %w(check_box_list select).freeze unless defined?(MULTIPLE_ARRAY_TAGS)

          scope :listable, -> { all }
          scope :not_internal, -> { where.not(internal: true) }
          scope :shared, -> { where(public: true) }
          scope :with_changed_attributes, ->(target_id, target_type, updated_at) { where('target_id = ? AND target_type = ? AND updated_at > ?', target_id, target_type, updated_at) }

          validates_presence_of :name, :attribute_type
          validates_uniqueness_of :name, scope: [:target_id, :target_type, :deleted_at]
          validates_inclusion_of :html_tag, in: HTML_TAGS, allow_blank: true

          belongs_to :target, -> { with_deleted }, polymorphic: true, touch: true
          belongs_to :instance

          serialize :valid_values, Array
          store :input_html_options
          store :wrapper_html_options

          attr_accessor :input_html_options_string, :wrapper_html_options_string

          before_save :normalize_name
          before_save :normalize_html_options

          def self.clear_cache(target_type, target_id)
            ::CustomAttributes::CustomAttribute::CacheDataHolder.destroy(target_id, target_type)
          end

          def self.get_from_cache(target_id, target_type)
            ::CustomAttributes::CustomAttribute::CacheDataHolder.fetch(target_id, target_type) do
              find_as_array(target_id, target_type)
            end
          end

          def normalize_name
            self.name = name.to_s.tr(' ', '_').underscore.downcase
          end

          def normalize_html_options
            self.input_html_options = normalize_input_html_options unless input_html_options_string.nil?
            self.wrapper_html_options = normalize_wrapper_html_options unless wrapper_html_options_string.nil?
            true
          end

          def normalize_input_html_options
            transform_hash_string_to_hash(input_html_options_string)
          end

          def normalize_wrapper_html_options
            transform_hash_string_to_hash(wrapper_html_options_string)
          end

          def transform_hash_string_to_hash(hash_string)
            hash = {}
            hash_string.scan(/([^, ]+) ?=> ?('[^']+'|"[^"]+"|[^,]+)/) { |key, value| hash[key.strip] = value.strip }
            hash
          end

          def self.cashed_attribute_names
            # Order is very important! if you need to add something, add it at the end
            [
              :name, :attribute_type, :default_value, :public, :valid_values, :html_tag,
              :searchable, :search_in_query
            ]
          end

          def self.find_as_array(target_id, target_type)
            where(target_id: target_id, target_type: target_type).pluck(*cashed_attribute_names)
          end

          def valid_values_casted
            return valid_values if attribute_type.to_sym == :array
            valid_values.map { |value| custom_property_type_cast(value, attribute_type.to_sym) }
          end

          def valid_values_translated
            if attribute_type == 'string'
              valid_values.map do |valid_value|
                [I18n.translate(valid_value_translation_key(valid_value), default: valid_value), valid_value]
              end
            else
              valid_values_casted.map { |val| [val, val] }
            end
          end

          %w(label hint placeholder prompt).each do |element|
            define_method "#{element}_key" do
              "#{translation_key_prefix}.#{element.pluralize}.#{name}"
            end

            define_method "#{element}_key_was" do
              "#{translation_key_prefix_was}.#{element.pluralize}.#{name}"
            end
          end

          def valid_value_translation_key(valid_value)
            "#{translation_key_prefix}.valid_values.#{name}.#{underscore(valid_value)}"
          end

          def translation_key_prefix
            target.translation_namespace
          end

          def translation_key_prefix_was
            target.translation_namespace_was
          end

          def translation_key_suffix
            target.translation_key_suffix + '.' + name
          end

          def translation_key_suffix_was
            target.translation_key_suffix_was + '.' + name
          end

          def translation_key_pluralized_suffix
            target.translation_key_pluralized_suffix + '.' + name
          end

          def underscore(string)
            string.underscore.tr(' ', '_')
          end

          def target_type=(sType)
            super(sType.to_s)
          end

          def self.custom_attributes_mapper(_klass, targets)
            if _klass.table_exists?
              all_custom_attributes = where(target: targets).pluck(:name, :attribute_type).uniq
              all_custom_attributes.map do |name, type|
                yield [name, attribute_type_to_es_type(type)]
              end
            end
          end

          def self.attribute_type_to_es_type(type)
            case type
            when 'integer', 'boolean', 'float' then type
            when 'decimal' then 'float'
            else
              'string'
            end
          end
        end
      end
    end
  end
end
