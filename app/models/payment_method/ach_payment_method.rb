require 'plaid'

class PaymentMethod::AchPaymentMethod < PaymentMethod

  has_many :payment_sources, class_name: 'BankAccount', foreign_key: 'payment_method_id' 

  def self.settings
    {
      client_id: { validate: [:presence], label:  "Plaid client_id" },
      public_key: { validate: [:presence], label: "Plaid public_key" },
      secret: { validate: [:presence], label: "Plaid secret" }
    }
  end

  def key
    settings && settings[:public_key]
  end

  def plaid_configured?
    return false unless key.present? && settings[:client_id].present? && settings[:secret].present?

    Plaid.config do |p|
      p.client_id = settings[:client_id]
      p.secret = settings[:secret]
      p.env = payment_gateway.test_mode? ? :tartan : :production
    end

    true
  end

end
