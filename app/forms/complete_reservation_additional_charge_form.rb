require 'reform/form/coercion'

class CompleteReservationAdditionalChargeForm < Reform::Form
  include Coercion

  property :name, validates: { presence: true }
  property :amount, validates: { presence: true, numericality: { only_integer: false } }
  property :status
  property :_destroy, writeable: false

  validates :name, :amount, presence: true

  delegate :new_record?, :marked_for_destruction?, :decorate, to: :model

  def sync
    model.try(:commission_receiver=, 'host')
    model.try(:status=, 'mandatory')
    super
  end

  def _destroy=(value)
    model.mark_for_destruction if value == '1'
  end

end
