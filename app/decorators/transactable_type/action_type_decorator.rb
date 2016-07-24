class TransactableType::ActionTypeDecorator < Draper::Decorator
  include CurrencyHelper

  delegate_all

  def availabile_units_with_i18n
    available_units.map do |unit|
      [I18n.t("pricing.instance_admin.#{unit}", count: 1), unit]
    end
  end

end