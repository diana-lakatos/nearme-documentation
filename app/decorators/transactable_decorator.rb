# frozen_string_literal: true
class TransactableDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include CurrencyHelper

  delegate_all

  def user_message_recipient(_current_user)
    administrator
  end

  def user_message_summary(user_message)
    link_to user_message.thread_context.name, user_message.thread_context.decorate.show_path
  end

  def price_with_currency(price_name_or_object)
    actual_price = nil
    actual_price = if price_name_or_object.respond_to?(:fractional)
                     price_name_or_object
                   else
                     send(price_name_or_object)
                   end

    render_money(Money.new(actual_price.try(:fractional), currency.blank? ? PlatformContext.current.instance.default_currency : currency))
  end

  # TODO: Refactor
  def lowest_price_with_currency(filter_pricing = [])
    return if action_type.is_free_booking?
    if event_booking?
      if event_booking.pricing.price.to_f > 0
        "#{price_with_currency(event_booking.pricing.price)} <span>/ #{transactable_type.action_price_per_unit? ? t('simple_form.labels.transactable.price.per_unit') : t('simple_form.labels.transactable.price.fixed')}</span>".html_safe
      elsif event_booking.pricing.exclusive_price.to_f > 0
        "#{price_with_currency(event_booking.pricing.exclusive_price)} <span>/ #{t('simple_form.labels.transactable.price.exclusive_price')}</span>".html_safe
      end
    else
      listing_price = lowest_price_with_type(filter_pricing)
      if listing_price
        translated_period = listing_price.decorate.units_translation('search.per_unit_price', 'search')
        "#{price_with_currency(listing_price.price)} <span>/ #{translated_period}</span>".html_safe
      end
    end
  end

  def price_per_unit?
    transactable_type.action_price_per_unit?
  end

  def listing_date
    I18n.l(created_at.to_date, format: :short)
  end

  def show_path(options = {})
    build_link('path', options)
  end

  def show_url(options = {})
    options.reverse_merge!(host: PlatformContext.current.decorate.host)
    build_link('url', options)
  end

  def customizations_for(custom_model)
    customizations.select { |c| c.custom_model_type == custom_model }.sort_by { |c| c.created_at || 1.day.from_now }
  end

  protected

  def build_link(suffix = 'path', options = {})
    options[:language] = I18n.locale if PlatformContext.current.multiple_languages?
    if transactable_type.show_path_format
      case transactable_type.show_path_format
      when '/:transactable_type_id/:id'
        h.send(:"short_transactable_type_listing_#{suffix}", transactable_type, self, options)
      when '/listings/:id'
        h.send(:"listing_#{suffix}", self, options)
      when '/transactable_types/:transactable_type_id/locations/:location_id/listings/:id'
        h.send(:"transactable_type_location_listing_#{suffix}", transactable_type, location, self, options)
      when '/:transactable_type_id/locations/:location_id/listings/:id'
        h.send(:"short_transactable_type_location_listing_#{suffix}", transactable_type, location, self, options)
      when '/:transactable_type_id/:location_id/listings/:id'
        h.send(:"short_transactable_type_short_location_listing_#{suffix}", transactable_type, location, self, options)
      when '/locations/:location_id/:id'
        h.send(:"location_#{suffix}", location, self, options)
      when '/locations/:location_id/listings/:id'
        h.send(:"location_listing_#{suffix}", location, self, options)
      end
    elsif transactable_type.show_page_enabled?
      h.send(:"location_listing_#{suffix}", location, self, options)
    else
      h.send(:"location_#{suffix}", location, self, options)
    end
  end
end
