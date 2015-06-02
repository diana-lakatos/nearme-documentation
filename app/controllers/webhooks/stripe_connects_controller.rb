class Webhooks::StripeConnectsController < ActionController::Base

  def webhook
    if request.post? && merchant_account = MerchantAccount::StripeConnectMerchantAccount.find_by(internal_payment_gateway_account_id: params[:user_id])
      event = Stripe::Event.retrieve(params[:id], merchant_account.data[:secret_key])

      case event.type
      when 'account.updated'
        merchant_account.webhooks.create!(response: params.to_yaml)
        account = Stripe::Account.retrieve(event.data.object.id)
        merchant_account.change_state_if_needed(account)
        if account.verification.fields_needed.present?
          merchant_account.update_column :data, merchant_account.data.merge(fields_needed: account.verification.fields_needed)
        end
      end
    end
  ensure
    render nothing: true
  end

end

