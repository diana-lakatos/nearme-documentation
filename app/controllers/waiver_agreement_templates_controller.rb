class WaiverAgreementTemplatesController < ApplicationController
  def show
    @transactable = Transactable.find_by(id: params[:transactable_id])
    @waiver_agreement_template = WaiverAgreementTemplate.find(params[:id])
  end
end
