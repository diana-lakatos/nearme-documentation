require 'reform/form/coercion'

class CompleteReservationPeriodForm < Reform::Form
  include Coercion
  include CurrencyHelper

  property :date
  property :description
  property :hours, type: Float, validates: { presence: true, numericality: { only_integer: false, greater_than: 0 } }
  property :created_at
  property :_destroy, writeable: false

  validates :description, :hours, presence: true

  delegate :new_record?, :marked_for_destruction?, :decorate, :reservation, :created_at, to: :model

  def sub_total(unit_price = nil)
    (unit_price || reservation.unit_price) * hours.to_f
  end

  def sub_total_formatted
    humanized_money_with_cents_and_symbol(sub_total)
  end

  def _destroy=(value)
    model.mark_for_destruction if value == '1'
  end

  def prepopulate!(reservation, default_hours = 1)
    unless model.reservation
      model.reservation = reservation
      if hours == 0
        model.hours = default_hours
        self.hours = model.hours
      end
    end
  end

  def created_at
    super || Time.zone.now
  end

end
