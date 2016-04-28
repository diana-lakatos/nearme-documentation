class MerchantAccount::PaypalAdaptiveMerchantAccount < MerchantAccount

  ATTRIBUTES = %w(email)
  include MerchantAccount::Concerns::DataAttributes

  after_create :verify

  validates :email, email: true, allow_blank: false

end


