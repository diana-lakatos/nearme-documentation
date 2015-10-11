class TransactableDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def user_message_recipient
    administrator
  end

  def user_message_summary(user_message)
    link_to user_message.thread_context.name, location_path(user_message.thread_context.location, user_message.thread_context)
  end

  def price_with_currency(price_name_or_object)
    actual_price = nil
    if price_name_or_object.respond_to?(:fractional)
      actual_price = price_name_or_object
    else
      actual_price = self.send(price_name_or_object)
    end

    humanized_money_with_symbol(Money.new(actual_price.try(:fractional), currency.blank? ? PlatformContext.current.instance.default_currency : currency))
  end

  def lowest_price_with_currency(filter_pricing = [])
    if self.schedule_booking?
      if self.fixed_price.to_f > 0
        "#{self.price_with_currency(self.fixed_price)} <span>/ #{self.transactable_type.action_price_per_unit? ? t("simple_form.labels.transactable.price.per_unit") : t("simple_form.labels.transactable.price.fixed")}</span>".html_safe
      elsif self.exclusive_price.to_f > 0
        "#{self.price_with_currency(self.exclusive_price)} <span>/ #{t("simple_form.labels.transactable.price.exclusive_price")}</span>".html_safe
      end
    else
      listing_price = self.lowest_price_with_type(filter_pricing)
      if listing_price
        periods = {monthly: t('periods.month'), weekly: t('periods.week'), monthly_subscription: t('periods.month'), weekly_subscription: t('periods.week'), daily: self.try(:overnight_booking?) ? t('periods.night') : t('periods.day'), hourly: t('periods.hour')}
        translated_period = I18n.t("dashboard.transactables.pricing_periods.#{periods[listing_price[1]]}")
        "#{self.price_with_currency(listing_price[0])} <span>/ #{translated_period}</span>".html_safe
      end
    end
  end

  def actions_allowed?
    !self.transactable_type.action_na
  end

  def price_per_unit?
    self.transactable_type.action_price_per_unit?
  end

  def first_available_occurrence
    start_date = Date.strptime(params[:start_date], "%m/%d/%Y") if params[:start_date]
    @first_occurrence ||= next_available_occurrences(1, { start_date: start_date }).first || {}
  end

end
