class PaymentTransferBuilderForReport
  include CurrencyHelper

  attr_reader :results

  def initialize(object)
    @object = object
    @results = []
  end

  def add_company
    @results << (@object.company.present? ? @object.company.name : "#{@object.company_including_deleted.name} (#{t('instance_admin.deleted')})")
  end

  def add_payments_count
    @results << @object.payments.count
  end

  def add_created_at_date
    @results << I18n.l(@object.created_at, format: :long)
  end

  def add_transferred_at
    if @object.transferred_at.present?
      @results << I18n.l(@object.transferred_at, format: :long)
    else
      if @object.pending?
        @results << I18n.t('instance_admin.manage.transfers.pending')
      elsif @object.payout_processor.present? && !@object.payout_processor.supports_immediate_payout?
        @results << I18n.t('instance_admin.manage.transfers.retry_possible')
      else
        @results << I18n.t('instance_admin.not_available_na')
      end
    end
  end

  def add_service_and_host_fees
    if PlatformContext.current.instance.guest_fee_enabled? && PlatformContext.current.instance.host_fee_enabled?
      @results << render_money(@object.service_fee_amount_guest)
      @results << render_money(@object.service_fee_amount_host)
    end
  end

  def add_total_service_fee
    @results << render_money(@object.total_service_fee)
  end

  def add_payment_gateway_fee
    @results << render_money(@object.payment_gateway_fee)
  end

  def add_transfer_amount
    @results << render_money(@object.amount)
  end

end
