# frozen_string_literal: true
class ApprovalRequestDrop < BaseDrop
  # @return [ApprovalRequest]
  attr_reader :approval_request

  # @!method notes
  #   returns the notes written by Administrator
  #   @return (see ApprovalRequest#notes)
  # @!method message
  #   returns the message written by Creator
  #   @return (see ApprovalRequest#message)
  delegate :notes, :message, to: :approval_request

  def initialize(approval_request)
    @approval_request = approval_request
  end
end
