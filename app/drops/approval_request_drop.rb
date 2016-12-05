# frozen_string_literal: true
class ApprovalRequestDrop < BaseDrop
  # @return [ApprovalRequest]
  attr_reader :approval_request

  # @!method notes
  #   @return [String] returns the notes written by Administrator
  # @!method message
  #   @return [String] returns the message written by Creator
  delegate :notes, :message, to: :approval_request

  def initialize(approval_request)
    @approval_request = approval_request
  end
end
