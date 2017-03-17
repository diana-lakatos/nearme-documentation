# frozen_string_literal: true
class PhotoForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  property :image
  validates :image, presence: true
end
