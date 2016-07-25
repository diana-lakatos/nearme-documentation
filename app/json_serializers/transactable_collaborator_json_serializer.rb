class TransactableCollaboratorJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :approved_by_user_at
  attribute :approved_by_owner_at

  has_one :user, include_links: false
  has_one :transactable, include_links: false
end
