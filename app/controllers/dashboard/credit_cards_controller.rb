class Dashboard::CreditCardsController < ApplicationController
  def destroy
    credit_card = CreditCard.find(params[:id])
    client = credit_card.instance_client.client
    if current_user == client || current_user.companies.include?(client)
      credit_card.destroy
    else
      flash[:error] = t('payments.cc_fields.cannot_delete')
    end
    redirect_to :back
  end
end
