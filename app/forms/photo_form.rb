# frozen_string_literal: true
class PhotoForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections

  # @!attribute image
  #   @return [File] file object associated with the photo
  property :image
  validates :image, presence: true
end
