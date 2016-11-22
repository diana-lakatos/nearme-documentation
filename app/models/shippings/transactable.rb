# frozen_string_literal: true
module Shippings
  module Transactable
    extend ActiveSupport::Concern

    included do
      # TODO: validate presence of
      # restrict_with_error
      has_one :transactable_dimensions_template, dependent: :restrict_with_error, inverse_of: :transactable
      has_one :dimensions_template, through: :transactable_dimensions_template

      accepts_nested_attributes_for :transactable_dimensions_template, allow_destroy: true

      validates :transactable_dimensions_template, presence: { if: ->(record) { Shippings.enabled?(record) } }
    end
  end
end
