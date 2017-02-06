# frozen_string_literal: true
class OrderDecorator < Draper::Decorator
  include MoneyRails::ActionViewExtension
  include Draper::LazyHelpers

  delegate_all

  # @todo Investigate for removal, these do not appear valid
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages, :shipping_address, to: :source

  def purchase?
    object.class == Purchase
  end

  def shipping_address_required?
    with_delivery?
  end

  def billing_address_required?
    with_delivery?
  end

  delegate :location, to: :transactable

  def user_message_recipient(current_user)
    current_user == owner ? creator : owner
  end

  def payment_decorator
    (payment || build_payment(shared_payment_attributes)).decorate
  end

  def payment_subscription_decorator
    (payment_subscription || build_payment_subscription(shared_payment_subscription_attributes)).decorate
  end

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

    state = 'Shipped' if object.shipped?

    state
  end

  def estimated_delivery
    # TODO: fix with shipping
    return 'Soon'
    result = 'N/A'

    object.shipments.each do |shipment|
      next unless shipment.state == 'shipped'
      next if shipment.shipping_method.processing_time.blank?

      processing_time = shipment.shipping_method.processing_time.to_i
      next unless processing_time > 0
      date = (shipment.shipped_at + processing_time.days).to_date
      result = I18n.l(date, format: :long)
      break
    end

    result
  end

  def company_name
    content_tag :strong, object.company.try(:name)
  end

  def payment_documents
    if object.payment_documents.blank?
      transactables.each do |transactable|
        transactable.document_requirements.select(&:should_show_file?).each_with_index do |doc, _index|
          object.payment_documents.build(
            user: @user,
            attachable: self,
            payment_document_info_attributes: {
              attachment_id: id,
              document_requirement_id: doc.id
            }
          )
        end
      end
    end
    object.payment_documents
  end

  def shipments
    # if object.transactable && object.transactable.possible_delivery?
    #   object.shipments.blank? ? object.shipments.build : object.shipments
    # end
    object.deliveries
  end

  def payment_state
    payment.state.try(:capitalize)
  end

  def payment
    object.payment.nil? ? object.build_payment(object.shared_payment_attributes) : object.payment
  end

  def billing_address
    object.billing_address.nil? ? fill_address_from_user(OrderAddress.new, true) : object.billing_address
  end

  def display_total
    render_money(object.total_amount)
  end

  # @return [String] total units as a text (e.g. "2 nights")
  #   the name is taken from the translations 'reservations.item.one' (for singular)
  #   and 'reservations.item.other' (for plural)
  def total_units_text
    unit = 'reservations.item'
    quantity = object.transactable_line_items.sum(:quantity)
    [quantity.to_i, I18n.t(unit, count: quantity)].join(' ')
  end

  def reviewable?(current_user)
    current_user != company.creator && approved_at.present? && paid? && shipped?
  end

  def self.column_headings_for_report
    values = []

    values << I18n.t('instance_admin.manage.orders.number')
    values << I18n.t('instance_admin.manage.orders.listing_name')
    values << I18n.t('instance_admin.manage.orders.listing_url')
    values << I18n.t('instance_admin.manage.orders.user')
    values << I18n.t('instance_admin.manage.orders.lister')
    values << I18n.t('instance_admin.manage.orders.payment')
    values << I18n.t('instance_admin.manage.orders.state')
    values << I18n.t('instance_admin.manage.orders.pro_bono')
    values << I18n.t('instance_admin.manage.orders.created_at')
    values << I18n.t('instance_admin.manage.orders.order_total_amount')
    values << I18n.t('instance_admin.manage.orders.order_amount_from_order_items')
    values << I18n.t('instance_admin.manage.orders.order_amount_from_payment')
    values << I18n.t('instance_admin.manage.orders.details')

    values
  end

  def column_values_for_report
    values = []

    values << object.id
    values << object.transactable.name
    values << object.transactable.decorate.show_url
    values << object.user.name
    values << object.transactable.creator.try(:name)
    values << object.payment.try(:id)
    values << object.state
    values << object.is_free_booking?
    values << object.created_at
    values << object.total_amount
    values << order.order_items.paid.map(&:total_amount).sum
    values << object.payment.try(:total_amount)
    values << instance_admin_manage_order_url(order)

    values
  end
  

  private

  def status_info(text)
    if completed?
      "<i class='ico-check'></i>".html_safe
    else
      tooltip(text, "<span class='tooltip-spacer'>i</span>".html_safe, { class: 'ico-pending' }, nil)
    end
  end

  # REFACTOR: use builder dp
  def fill_address_from_user(address, billing_address = true)
    address_info = billing_address ? user.billing_addresses.last : user.shipping_addresses.last

    address.attributes = address_info.dup.attributes if address_info
    address.firstname ||= user.first_name
    address.lastname ||= user.last_name
    address.phone ||= user.phone.to_s
    address.phone ||= "+#{user.country.calling_code} #{address.phone}" if user.country && !address.phone.include?('+')

    address
  end

end
