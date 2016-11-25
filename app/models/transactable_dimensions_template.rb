# frozen_string_literal: true
class TransactableDimensionsTemplate < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  scoped_to_platform_context
  auto_set_platform_context

  belongs_to :transactable, inverse_of: :transactable_dimensions_template
  belongs_to :dimensions_template

  validates :transactable, :dimensions_template, presence: true
end
