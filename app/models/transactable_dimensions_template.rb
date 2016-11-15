# frozen_string_literal: true
class TransactableDimensionsTemplate < ActiveRecord::Base
  belongs_to :transactable, inverse_of: :transactable_dimensions_template
  belongs_to :dimensions_template

  validates :transactable, :dimensions_template, presence: true
end
