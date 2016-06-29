class ReverseProxyLinkJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :name
  attribute :use_on_path
  attribute :destination_path

end

