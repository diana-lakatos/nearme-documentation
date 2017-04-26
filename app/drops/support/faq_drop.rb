# frozen_string_literal: true
class Support::FaqDrop < BaseDrop
  # @return [Support::TicketDrop]
  attr_reader :source

  # @!method id
  #   @return [Integer] id for the FAQ
  # @!method question
  #   @return [String] question for the FAQ item
  # @!method answer
  #   @return [String] answer for the FAQ item
  delegate :id, :question, :answer, to: :source

  def initialize(faq)
    @source = faq
  end
end
