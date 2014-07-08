class PartnerInquiriesController < ApplicationController
  before_filter :redirect_if_not_desksnearme

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

  def redirect_if_not_desksnearme
    redirect_to root_path if !platform_context.theme.is_desksnearme?
  end

  def inquiry_params
    params.require(:partner_inquiry).permit(secured_params.inquiry)
  end
end
