class PaymentTransferDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def transfer_status
    if transferred?
      'Paid'
    elsif payout_attempts.last.present?
      if pending?
        'Pending'
      elsif failed?
        'Failed'
      else
        'Paid'
      end
    else
      'N/A'
    end
  end

  def css_row_class
    if transferred?
      'success'
    elsif pending?
      'info'
    elsif failed?
      'danger'
    else
      'warning'
    end
  end

  def self.collection_decorator_class
    PaginatingDecorator
  end
end

