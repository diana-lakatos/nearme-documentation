Spree::Payment.class_eval do
  include Spree::Scoper

  def credit!(credit_amount)
    true
  end
end
