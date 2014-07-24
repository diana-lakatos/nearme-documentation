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
  scope :with_changed_attributes, -> updated_at { where('updated_at > ?', updated_at) }

  validates_presence_of :name, :attribute_type
  validates_uniqueness_of :name, :scope => [:transactable_type_id, :deleted_at]

  belongs_to :transactable_type, :inverse_of => :transactable_type_attributes
  belongs_to :instance

  serialize :valid_values, Array
  serialize :validation_rules, JSON
  store :input_html_options
  store :wrapper_html_options


  def self.find_as_array(transactable_type_id, attributes = [:name, :attribute_type, :default_value, :public])
    TransactableTypeAttribute.where(transactable_type_id: transactable_type_id).pluck(attributes)
  end

end

