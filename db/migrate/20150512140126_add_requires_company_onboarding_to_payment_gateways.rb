class AddRequiresCompanyOnboardingToPaymentGateways < ActiveRecord::Migration
  def up
    add_column :payment_gateways, :requires_company_onboarding, :boolean, default: false

    PaymentGateway.where(name: 'Braintree Marketplace').first_or_create! do |pg|
      pg.active_merchant_class = 'ActiveMerchant::Billing::BraintreeMarketplacePayments'
      pg.requires_company_onboarding =  true
      pg.settings = {
        merchant_id: '',
        public_key: '',
        private_key: '',
        supported_currency: '',
        master_merchant_account_id: ''
      }
    end
  end

  def down
    remove_column :payment_gateways, :requires_company_onboarding
  end
end

