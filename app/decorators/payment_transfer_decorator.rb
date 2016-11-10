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
end
