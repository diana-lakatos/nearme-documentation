class WaiverAgreementTemplateDrop < BaseDrop
  delegate :name, :content, :id, :created_at, to: :source
end
