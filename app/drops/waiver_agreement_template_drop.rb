class WaiverAgreementTemplateDrop < BaseDrop

  # @!method name
  #   Name of the waiver agreement template
  #   @return (see WaiverAgreementTemplate#name)
  # @!method content
  #   Waiver agreement template body text (e.g. list of terms and conditions text etc.)
  #   @return (see WaiverAgreementTemplate#content)
  # @!method id
  #   @return [Integer] numeric identifier of the waiver agreement template
  # @!method created_at
  #   @return [DateTime] date/time when the object was created
  delegate :name, :content, :id, :created_at, to: :source

end
