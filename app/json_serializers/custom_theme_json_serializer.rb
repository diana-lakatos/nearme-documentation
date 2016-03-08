# frozen_string_literal: true
class CustomThemeJsonSerializer
  include JSONAPI::Serializer

  attribute :name
  attribute :in_use
  attribute :in_use_for_instance_admins

  has_many :instance_views, include_links: false
  has_many :assets, include_links: false
end
