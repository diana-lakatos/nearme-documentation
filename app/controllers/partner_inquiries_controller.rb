class PartnerInquiriesController < ApplicationController

  def index
    @partner_inquiry = PartnerInquiry.new
  end

  def create
    @partner_inquiry = PartnerInquiry.new(inquiry_params)
    if @partner_inquiry.save
      render json: { body: t('flash_messages.partner_inquiries.inquiry_added'), status: true }
    else
      render json: { body: t('flash_messages.partner_inquiries.inquiry_not_added'), status: false }
    end
  end

  private

  def inquiry_params
    params.require(:partner_inquiry).permit(secured_params.inquiry)
  end
end
