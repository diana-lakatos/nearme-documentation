# frozen_string_literal: true
class WaiverAgreementTemplateDrop < BaseDrop
  # @!method name
  #   @return [String] Name of the waiver agreement template
  # @!method content
  #   @return [String] Waiver agreement template body text (e.g. list of terms and conditions text etc.)
  # @!method id
  #   @return [Integer] numeric identifier of the waiver agreement template
  # @!method created_at
  #   @return [DateTime] date/time when the object was created
  delegate :name, :content, :id, :created_at, to: :source
end
