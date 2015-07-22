class MerchantAccount::PaypalMerchantAccount < MerchantAccount

  ATTRIBUTES = %w(email)
  include MerchantAccount::Concerns::DataAttributes

end

