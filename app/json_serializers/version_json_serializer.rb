# frozen_string_literal: true
class VersionJsonSerializer
  include JSONAPI::Serializer

  attribute :author
  attribute :date
  attribute :content

  def type
    'version'
  end

  def self_link
    object.show_url
  end
end
