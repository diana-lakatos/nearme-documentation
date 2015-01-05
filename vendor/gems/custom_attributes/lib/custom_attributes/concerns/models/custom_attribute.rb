module CustomAttributes
  module Concerns
    module Models
      module CustomAttribute
        extend ActiveSupport::Concern

        included do
          self.table_name = 'custom_attributes'

          NAME = 0 unless defined?(NAME)
          ATTRIBUTE_TYPE = 1 unless defined?(ATTRIBUTE_TYPE)
          VALUE = 2 unless defined?(VALUE)
          PUBLIC = 3 unless defined?(PUBLIC)
          VALIDATION_RULES = 4 unless defined?(VALIDATION_RULES)
          VALID_VALUES = 5 unless defined?(VALID_VALUES)
          ATTRIBUTE_TYPES = %w(array string integer float decimal datetime time date binary boolean) unless defined?(ATTRIBUTE_TYPES)
          HTML_TAGS = %w(input select switch textarea check_box radio_buttons check_box_list) unless defined?(HTML_TAGS)

          scope :listable, -> { all }
          scope :not_internal, -> { where.not(internal: true) }
          scope :shared, -> { where(public: true) }
          scope :with_changed_attributes, -> (target_id, target_type, updated_at) { where('target_id = ? AND target_type = ? AND updated_at > ?', target_id, target_type, updated_at) }

          validates_presence_of :name, :attribute_type
          validates_uniqueness_of :name, :scope => [:target_id, :target_type, :deleted_at]
          validates_inclusion_of :html_tag, in: HTML_TAGS, allow_blank: true

          belongs_to :target, polymorphic: true
          belongs_to :instance

          serialize :valid_values, Array
          serialize :validation_rules, JSON
          store :input_html_options
          store :wrapper_html_options

          attr_accessor :input_html_options_string, :wrapper_html_options_string

          before_save :normalize_name
          before_save :normalize_html_options

          def self.clear_cache(target_type)
            target_type.constantize.pluck(:id).each do |target_id|
              if (timestamp = ::CustomAttributes::CustomAttribute::CacheTimestampsHolder.get(target_id, target_type)).present?
                if self.with_changed_attributes(target_id, target_type, timestamp).count > 0
                  ::CustomAttributes::CustomAttribute::CacheDataHolder.destroy(target_id, target_type)
                end
              end
              count = ::CustomAttributes::CustomAttribute::CacheCountHolder.get(target_id, target_type)
              if self.where(target_id: target_id, target_type: target_type).count != count
                ::CustomAttributes::CustomAttribute::CacheCountHolder.store(target_id, target_type, count)
                ::CustomAttributes::CustomAttribute::CacheDataHolder.destroy(target_id, target_type)
              end
            end
          end

          def self.get_from_cache(target_id, target_type)
            ::CustomAttributes::CustomAttribute::CacheDataHolder.fetch(target_id, target_type) do
              ::CustomAttributes::CustomAttribute::CacheTimestampsHolder.touch(target_id, target_type)
              self.find_as_array(target_id, target_type)
            end
          end

          def normalize_name
            self.name = self.name.to_s.tr(' ', '_').underscore.downcase
          end

          def normalize_html_options
            self.input_html_options = normalize_input_html_options if input_html_options_string.present?
            self.wrapper_html_options = normalize_wrapper_html_options if wrapper_html_options_string.present?
          end

          def normalize_input_html_options
            transform_hash_string_to_hash(input_html_options_string)
          end

          def normalize_wrapper_html_options
            transform_hash_string_to_hash(wrapper_html_options_string)
          end

          def transform_hash_string_to_hash(hash_string)
            hash_string.split(',').inject({}) do |hash, key_value_string|
              key_value_arr = key_value_string.split('=>')
              hash[key_value_arr[0].strip] = key_value_arr[1].strip
              hash
            end
          end

          def self.find_as_array(target_id, target_type)
            self.where(target_id: target_id, target_type: target_type).pluck(:name, :attribute_type, :default_value, :public, :validation_rules, :valid_values)
          end

          def valid_values_translated
            valid_values.map do |valid_value|
              [I18n.translate(valid_value_translation_key(valid_value)), valid_value]
            end
          end

          def label_key
            "simple_form.labels.#{translation_key_suffix}"
          end

          def hint_key
            "simple_form.hints.#{translation_key_suffix}"
          end

          def placeholder_key
            "simple_form.placeholders.#{translation_key_suffix}"
          end

          def prompt_key
            "simple_form.prompts.#{translation_key_suffix}"
          end

          def valid_value_translation_key(valid_value)
            "simple_form.valid_values.#{translation_key_suffix}.#{underscore(valid_value)}"
          end

          def translation_key_suffix
            underscore(self.target.name) + '.' + name
          end

          def translation_key_pluralized_suffix
            underscore(self.target.name.pluralize) + '.' + name
          end

          def underscore(string)
            string.underscore.tr(' ', '_')
          end

        end

      end
    end
  end
end

