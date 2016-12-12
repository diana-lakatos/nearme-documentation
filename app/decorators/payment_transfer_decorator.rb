# frozen_string_literal: true
class PaymentTransferDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def transfer_status
    if pending?
      I18n.t('instance_admin.pending')
    elsif failed?
      I18n.t('instance_admin.failed')
    elsif transferred?
      I18n.t('instance_admin.paid')
    else
      I18n.t('instance_admin.not_vailable')
    end
  end

  def css_row_class
    if failed?
      'danger'
    elsif transferred?
      'success'
    elsif pending?
      'info'
    else
      'warning'
    end
  end

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def column_values_for_report
    payment_transfer_builder = PaymentTransferBuilderForReport.new(object)

    payment_transfer_builder.add_company
    payment_transfer_builder.add_payments_count
    payment_transfer_builder.add_created_at_date
    payment_transfer_builder.add_transferred_at
    payment_transfer_builder.add_service_and_host_fees
    payment_transfer_builder.add_total_service_fee
    payment_transfer_builder.add_payment_gateway_fee
    payment_transfer_builder.add_transfer_amount

    payment_transfer_builder.results
  end

  def self.column_headings_for_report
    values = []
    values << I18n.t('instance_admin.manage.transfers.company')
    values << I18n.t('instance_admin.manage.transfers.charges')
    values << I18n.t('instance_admin.manage.transfers.created_at')
    values << I18n.t('instance_admin.manage.transfers.transferred_at')
    if PlatformContext.current.instance.guest_fee_enabled? && PlatformContext.current.instance.host_fee_enabled?
      values << I18n.t('instance_admin.manage.transfers.lessor_service_fees')
      values << I18n.t('instance_admin.manage.transfers.lessee_service_fees')
    end
    values << I18n.t('instance_admin.manage.transfers.total_fee')
    values << I18n.t('instance_admin.manage.transfers.payment_gateway_fee')
    values << I18n.t('instance_admin.manage.transfers.transfer_amount')

    values
  end

  def payment_gateway_url
    payment_gateway.transfer_url(self)
  end
end
