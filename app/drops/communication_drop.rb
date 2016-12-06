# frozen_string_literal: true
class CommunicationDrop < BaseDrop
  # @!method verified
  #   @return [Boolean] Whether this communication type is verified
  # @!method user
  #   @return [UserDrop] Owner of this communication type
  delegate :verified, :user, to: :source
end
