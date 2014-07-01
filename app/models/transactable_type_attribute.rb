class TransactableTypeAttribute < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  # attr_accessible :name, :transactable_type_id, :attribute_type, :html_tag,
  #   :prompt, :default_value, :public, :validation_rules, :valid_values, :label,
  #   :placeholder, :hint, :input_html_options, :wrapper_html_options, :deleted_at,
  #   :internal

  validates_presence_of :name, :attribute_type
  validates_uniqueness_of :name, :scope => [:transactable_type_id, :deleted_at]

  belongs_to :transactable_type, :inverse_of => :transactable_type_attributes
  belongs_to :instance

  serialize :valid_values, Array
  serialize :validation_rules, JSON
  store :input_html_options
  store :wrapper_html_options

end

