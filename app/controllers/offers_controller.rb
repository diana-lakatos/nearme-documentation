class OffersController < ApplicationController
  before_filter :find_offer # , only: [:show]
  before_filter :redirect_if_draft # , only: [:show]

  def show
  end

  protected

  def find_offer
    @offer = Offer.find(params[:id])
  end

  def redirect_if_draft
    redirect_to root_url, notice: I18n.t('flash_messages.offer.draft') if @offer.draft_at && @offer.creator != current_user
  end
end
