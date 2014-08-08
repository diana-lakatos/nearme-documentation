class TransactableTypeAttribute < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  # attr_accessible :name, :transactable_type_id, :attribute_type, :html_tag,
  #   :prompt, :default_value, :public, :validation_rules, :valid_values, :label,
  #   :placeholder, :hint, :input_html_options, :wrapper_html_options, :deleted_at,
  #   :internal

  scope :listable, -> { all }
  scope :not_internal, -> { where.not(internal: true) }
  scope :public, -> { where(public: true) }

  validates_presence_of :name, :attribute_type
  validates_uniqueness_of :name, :scope => [:transactable_type_id, :deleted_at]

  belongs_to :transactable_type, :inverse_of => :transactable_type_attributes
  belongs_to :instance

  serialize :valid_values, Array
  serialize :validation_rules, JSON
  store :input_html_options
  store :wrapper_html_options

  attr_accessor :input_html_options_string, :wrapper_html_options_string

  before_save :normalize_name
  before_save :normalize_html_options

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

end

