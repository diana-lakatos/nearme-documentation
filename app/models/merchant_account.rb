class MerchantAccount < ActiveRecord::Base

  auto_set_platform_context
  scoped_to_platform_context

  SEPARATE_TEST_ACCOUNTS = false

  attr_encrypted :response, key: DesksnearMe::Application.config.secret_token, if: DesksnearMe::Application.config.encrypt_sensitive_db_columns, marshal: true

  has_many :webhooks, as: :webhookable, dependent: :destroy

  # Relates with Company
  belongs_to :merchantable, polymorphic: true
  belongs_to :instance
  belongs_to :payment_gateway

  # need to mention specific merchant accounts after associations
  MERCHANT_ACCOUNTS = {
    'braintree_marketplace' => MerchantAccount::BraintreeMarketplaceMerchantAccount,
    'stripe_connect'        => MerchantAccount::StripeConnectMerchantAccount,
    'paypal'                => MerchantAccount::PaypalMerchantAccount,
    'paypal_adaptive'       => MerchantAccount::PaypalAdaptiveMerchantAccount,
    'paypal_express_chain'  => MerchantAccount::PaypalExpressChainMerchantAccount
  }

  validates_presence_of :merchantable_id, :merchantable_type, :unless => lambda { |ic| ic.merchantable.present? }
  validate :data_correctness

  scope :verified_on_payment_gateway, -> (payment_gateway_id) { verified.where('merchant_accounts.payment_gateway_id = ?', payment_gateway_id) }
  scope :pending,  -> { where(state: 'pending') }
  scope :verified, -> { where(state: 'verified') }
  scope :failed,   -> { where(state: 'failed') }

  attr_accessor :skip_validation

  before_create :set_test_mode_if_necessary, if: -> { self.class::SEPARATE_TEST_ACCOUNTS }
  before_create :onboard!
  before_update :update_onboard!, unless: lambda { |merchant_account| merchant_account.skip_validation }

  state_machine :state, initial: :pending do
    event :to_pending do
      transition [:verified, :failed] => :pending
    end

    event :verify do
      transition [:pending, :failed] => :verified
    end

    event :failure do
      transition [:pending, :verified] => :failed
    end
  end

  def to_liquid
    @mechant_account_drop ||= MerchantAccountDrop.new(self)
  end

  def data_correctness(*args)
  end

  def onboard!(*args)
  end

  def update_onboard!(*args)
  end

  private

  def set_test_mode_if_necessary
    self.test = PlatformContext.current.instance.test_mode?
    true
  end

  def redirect_url
    Rails.application.routes.url_helpers.edit_dashboard_company_payouts_path
  end
end

