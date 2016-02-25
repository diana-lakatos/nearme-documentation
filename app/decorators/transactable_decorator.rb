class TransactableDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def user_message_recipient
    administrator
  end

  def user_message_summary(user_message)
    link_to user_message.thread_context.name, user_message.thread_context.decorate.show_path
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
    start_date = Date.strptime(params[:start_date], "%m/%d/%Y") if params[:start_date].present?
    @first_occurrence ||= next_available_occurrences(1, { start_date: start_date }).first || {}
  end

  def listing_date
    I18n.l(created_at.to_date, format: :short)
  end

  def show_path(options = {})
    build_link('path', options)
  end

  def show_url(options = {})
    build_link('url', options)
  end

  protected

  def build_link(suffix = 'path', options = {})
    options.merge!(language: I18n.locale) if PlatformContext.current.try(:instance).try(:available_locales).try(:many?)
    if transactable_type.show_path_format
      case transactable_type.show_path_format
      when "/:transactable_type_id/:id"
        h.send(:"short_transactable_type_listing_#{suffix}", transactable_type, self, options)
      when "/listings/:id"
        h.send(:"listing_#{suffix}", self, options)
      when "/transactable_types/:transactable_type_id/locations/:location_id/listings/:id"
        h.send(:"transactable_type_location_listing_#{suffix}", transactable_type, location, self, options)
      when "/:transactable_type_id/locations/:location_id/listings/:id"
        h.send(:"short_transactable_type_location_listing_#{suffix}", transactable_type, location, self, options)
      when "/:transactable_type_id/:location_id/listings/:id"
        h.send(:"short_transactable_type_short_location_listing_#{suffix}", transactable_type, location, self, options)
      when "/locations/:location_id/:id"
        h.send(:"location_#{suffix}", location, self, options)
      when "/locations/:location_id/listings/:id"
        h.send(:"location_listing_#{suffix}", location, self, options)
      end
    elsif transactable_type.show_page_enabled?
      h.send(:"location_listing_#{suffix}", location, self, options)
    else
      h.send(:"location_#{suffix}", location, self, options)
    end

  end

end
