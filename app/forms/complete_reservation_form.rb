class CompleteReservationForm < Reform::Form
  include Reform::Form::ActiveModel::ModelReflections
  model Reservation

  property :comment
  property :pending_guest_confirmation

  collection :periods, populate_if_empty: ReservationPeriod, form: CompleteReservationPeriodForm
  collection :additional_charges, populate_if_empty: AdditionalCharge, form: CompleteReservationAdditionalChargeForm

  validate :total_is_positive

  def initialize(*args)
    super(*args)
  end

  def sync
    self.pending_guest_confirmation = Time.zone.now
    periods.each(&:sync)
    additional_charges.each(&:sync)
    super
    model.calculate_prices
  end

  protected

  def total_is_positive
    self.errors.add(:sub_total, I18n.t('activemodel.errors.models.reservation_checkout_form.attributes.sub_total.must_be_positive')) if (valid_additional_charges.sum(&:amount) + valid_periods.sum { |p| p.sub_total(model.unit_price) }.to_f) <= 0
  end

  def valid_additional_charges
    additional_charges.reject { |ac| ac.model.marked_for_destruction? }
  end

  def valid_periods
    periods.reject { |p| p.model.marked_for_destruction? }
  end

end

