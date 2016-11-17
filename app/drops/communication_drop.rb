# frozen_string_literal: true
class CommunicationDrop < BaseDrop
  # @!method verified
  #   Whether this communication type is verified
  #   @return (see Communication#verified)
  # @!method user
  #   @return [UserDrop] Owner of this communication type
  delegate :verified, :user, to: :source
end
