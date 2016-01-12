class CreditCardForm < Form
   attr_reader :number, :verification_value, :month, :year, :first_name, :last_name

  [:number, :verification_value, :month, :year, :first_name, :last_name].each do |accessor|
    define_method("#{accessor}=") do |attribute|
      instance_variable_set("@#{accessor}", attribute.try(:to_s).try(:strip))
    end

    define_method("#{accessor}") do
      @credit_card.send(accessor)
    end
  end

  def initialize(params = {})
    params ||= {}
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(params)
  end

  def to_active_merchant
    @credit_card
  end

  def valid?
    unless @credit_card.valid?
      errors.add(:cc, I18n.t('buy_sell_market.checkout.invalid_cc'))
      @credit_card.errors.each do |key,value|
        errors.add(key, value)
      end
      false
    else
      true
    end
  end
end
