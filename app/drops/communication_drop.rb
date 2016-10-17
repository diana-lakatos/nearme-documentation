class CommunicationDrop < BaseDrop
  # @!method verified
  #   Whether this communication type is verified
  #   @return (see Communication#verified)
  # @!method user
  #   Owner of this communication type
  #   @return (see Communication#user)
  delegate :verified, :user, to: :source
end
