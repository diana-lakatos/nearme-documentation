class WaiverAgreementTemplatesController < ApplicationController
  def show
    @waiver_agreement_template = WaiverAgreementTemplate.find(params[:id])
  end
end
