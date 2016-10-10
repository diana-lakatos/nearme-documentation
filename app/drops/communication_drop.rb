class CommunicationDrop < BaseDrop
  delegate :verified, :user, to: :source
end
