class Spree::OrderDecorator < Draper::Decorator
  include MoneyRails::ActionViewExtension
  include Draper::LazyHelpers

  delegate_all

  decorates_association :line_items

  delegate :company_name

  def my_order_status_info
    status_info("Pending payment")
  end

  def company_name
    content_tag :strong, object.company.name
  end

  def bill_address
    object.bill_address.nil? ? fill_address_from_user(object.build_bill_address) : object.bill_address
  end

  def ship_address
    object.ship_address.nil? ? fill_address_from_user(object.build_ship_address, false) : object.ship_address
  end

  def save_billing_address

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
    address_info = billing_address ? current_user.billing_address : current_user.shipping_address

    address.firstname = current_user.first_name
    address.lastname = current_user.last_name
    address.phone = "+#{current_user.country.calling_code}#{current_user.phone}"

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
