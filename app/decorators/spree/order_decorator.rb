class Spree::OrderDecorator < Draper::Decorator
  include MoneyRails::ActionViewExtension
  include Draper::LazyHelpers

  delegate_all

  decorates_association :line_items

  delegate :current_page, :per_page, :offset, :total_entries, :total_pages

  def my_order_status_info
    status_info('Pending payment')
  end

  def status
    state = case object.state
            when 'canceled'
              'Canceled'
            when 'confirm'
              'Confirmed'
            when 'complete'
              'Completed'
            when 'resumed'
              'Completed'
            else
              'N/A'
            end

    if object.shipped?
      state = 'Shipped'
    end

    state
  end

  def estimated_delivery
    result = 'N/A'

    object.shipments.each do |shipment|
      next unless shipment.state == 'shipped'
      next if shipment.shipping_method.processing_time.blank?

      processing_time = shipment.shipping_method.processing_time.to_i
      if processing_time > 0
        date = (shipment.shipped_at + processing_time.days).to_date
        result = I18n.l(date, format: :long)
        break
      end
    end

    result
  end

  def company_name
    content_tag :strong, object.company.try(:name)
  end

  def bill_address
    object.bill_address.nil? ? fill_address_from_user(object.build_bill_address) : object.bill_address
  end

  def ship_address
    object.ship_address.nil? ? fill_address_from_user(object.build_ship_address, false) : object.ship_address
  end

  def save_billing_address

  end

  def display_completed_at
    object.completed_at ? l(object.completed_at.to_date, format: :long) : ''
  end

  def display_total
    humanized_money_with_symbol(object.total.to_money(Spree::Config.currency))
  end

  def display_shipping_address
    shipping_address = []
    shipping_address << "#{object.ship_address.address1}, #{object.ship_address.city}"
    shipping_address << "#{object.ship_address.state_text}, #{object.ship_address.country.try(:iso).presence || object.ship_address.country.try(:name)}, #{object.ship_address.zipcode}"
    shipping_address.join("<br/>").html_safe
  end

  private

  def status_info(text)
    unless completed?
      tooltip(text, "<span class='tooltip-spacer'>i</span>".html_safe, { class: 'ico-pending' }, nil)
    else
      "<i class='ico-check'></i>".html_safe
    end
  end

  def fill_address_from_user(address, billing_address=true)
    address_info = billing_address ? current_user.billing_address : current_user.spree_shipping_address

    address.firstname = current_user.first_name
    address.lastname = current_user.last_name
    address.phone = "#{current_user.phone}"
    if current_user.country && !address.phone.include?('+')
      address.phone = "+#{current_user.country.calling_code} #{address.phone}"
    end

    if address_info
      address.address1 = address_info.address1
      address.address2 = address_info.address2
      address.city = address_info.city
      address.zipcode = address_info.zipcode
      address.country_id = address_info.country_id
      address.state_id = address_info.state_id
      address.state_name = address_info.state_name
    end

    address
  end
end
