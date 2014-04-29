class TransactableType < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context


  attr_accessible :name
  has_many :transactables, inverse_of: :transactable_type
  has_many :transactable_type_attributes, inverse_of: :transactable_type

  belongs_to :instance
end

