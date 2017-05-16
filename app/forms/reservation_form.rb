# frozen_string_literal: true
class ReservationForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections

  def initialize(model)
    super(model)
  end

  property :_destroy, virtual: true
  property :quantity, default: 1
  property :transactable_pricing_id
  property :transactable_id

  property :minimum_booking_minutes, readonly: true
  validates :minimum_booking_minutes, presence: true

  validates :transactable_pricing_id, presence: true
  validates :transactable_id, presence: true

  class << self
    def decorate(configuration)
      Class.new(self) do
        if (periods_configuration = configuration.delete(:periods))
          collection :periods, form: ReservationPeriodForm.decorate(periods_configuration),
                               populator: ->(fragment:, **) {
                                            item = periods.find { |p| p.id.to_s == fragment['id'].to_s && fragment['id'].present? }
                                            if fragment['_destroy'] == '1'
                                              periods.delete(item)
                                              return skip!
                                            end
                                            item ? item : periods.append(model.periods.build)
                                          },
                               prepopulator: ->(_options) { periods << model.periods.build if periods.size.zero? }
          validates :periods, presence: true, length: { minimum: 1 }
        end
        if (properties_configuration = configuration.delete(:properties)).present?
          add_validation(:properties, properties_configuration)
          property :properties, form: PropertiesForm.decorate(properties_configuration)
        end
        inject_dynamic_fields(configuration)
      end
    end
  end

  def validate!(*args)
    t = Transactable.find_by(id: @fields['transactable_id'])
    model.creator_id = t.creator_id
    model.company_id = t.company_id
    model.minimum_booking_minutes = t.time_based_booking&.minimum_booking_minutes
    super
  end

  def save!
    super
    # FIXME: for now to be able to update reservation. Big refactor required
    # idea - probably skip building line items entirely at this level, and move it
    # to CheckoutForm.
    model.line_items.destroy_all
    model.reload
    model.build_first_line_item
    model.save!
  end
end
