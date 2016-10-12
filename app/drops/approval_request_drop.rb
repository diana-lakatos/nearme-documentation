class ApprovalRequestDrop < BaseDrop
  attr_reader :approval_request

  # notes
  #   returns the notes written by Administrator
  # message
  #   returns the message written by Creator
  delegate :notes, :message, to: :approval_request

  def initialize(approval_request)
    @approval_request = approval_request
  end
end
