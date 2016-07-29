class InstanceJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :name

  attribute :domain_name do
    object.domains.map(&:name).join(', ')
  end

  # TODO: find a better way to determine a creator
  # TODO: question: do we need creator email?
  attribute :creator_email do
    object.users.first && object.users.first.email
  end

  attribute :contact_email do
    begin
      object.theme.support_email
    rescue
      'no support email for instance: ' + object.name
    end
  end
end
