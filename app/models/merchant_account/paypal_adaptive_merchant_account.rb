class MerchantAccount::PaypalAdaptiveMerchantAccount < MerchantAccount

  SEPARATE_TEST_ACCOUNTS = true

  ATTRIBUTES = %w(email)
  include MerchantAccount::Concerns::DataAttributes

  after_create :verify

end

