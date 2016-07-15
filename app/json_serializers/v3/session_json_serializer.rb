class V3::SessionJsonSerializer
  include JSONAPI::Serializer

  attribute :token
  def type
    'user'
  end
end
