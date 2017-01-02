# frozen_string_literal: true
class InstanceViewJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :path
  attribute :partial

  has_many :transactable_types
  has_many :locales
end
