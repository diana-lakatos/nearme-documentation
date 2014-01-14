# Encapsulate all billing  gateway related logic associated with a user
class Billing::Gateway

  attr_reader :user, :currency

  delegate :charge, :store_credit_card, :to => :processor

  def initialize(user, currency, instance)
    @user = user
    @currency = currency
    @instance = instance
  end

  def payment_supported?
    processor.present?
  end

  def processor
    @processor ||= Billing::Gateway::BaseProcessor.find_processor_class(@currency).try(:new, @user, @currency, @instance)
  end

end
