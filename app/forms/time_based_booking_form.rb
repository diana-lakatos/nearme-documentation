# frozen_string_literal: true
class TimeBasedBookingForm < ActionTypeForm
  model 'transactable/time_based_booking'

  class << self
    def decorate(configuration)
      Class.new(self) do
        super
        if (availability_configuration = configuration.delete(:availability_templates)).present?
          add_validation(:availability_templates, availability_configuration)
          validate :availability_rules_minimum_booking_minutes
          collection :availability_templates, form: AvailabilityTemplateForm.decorate(availability_configuration),
                                              prepopulator: ->(_option) { availability_templates << get_availability_template_object if availability_templates.blank? },
                                              populator: ->(fragment:, **) {
                                                           item = availability_templates.find { |at| at.id.to_s == fragment['id'].to_s && fragment['id'].present? }
                                                           if fragment['_destroy'] == '1'
                                                             availability_templates.delete(item)
                                                             return skip!
                                                          end
                                                           if item
                                                             model.availability_template = item.model
                                                             item
                                                           else
                                                             self.availability_template = model.availability_templates.new
                                                             availability_templates.append(availability_template)
                                                            end
                                                         }
        end
      end
    end
  end

  # @!attribute type
  #   @return [String] must be Transactable::TimeBasedBooking
  property :type, default: 'Transactable::TimeBasedBooking'

  # @!attribute availability_template
  #   @return [AvailabilityTemplateForm] {AvailabilityTemplateForm} for the time based booking
  property :availability_template

  # @!attribute minimum_booking_minutes
  #   @return [Integer] minimum number of minutes for a booking of this type
  property :minimum_booking_minutes

  # @!attribute minimum_booking_hours
  #   @return [Integer] minimum number of hours for a booking of this type
  property :minimum_booking_hours, virtual: true

  # @!attribute availability_template_id
  #   @return [Integer] numeric identifier for the associated availability template
  property :availability_template_id,
           populator: ->(fragment:, **) {
             if fragment.to_i > 0
               self.availability_template_id = fragment
             else
               return skip!
             end
           }

  # @!attribute availability_templates
  #   @return [Array<AvailabilityTemplateForm>] array of {AvailabilityTemplateForm} associated with the time
  #     based booking; note: only the 'availability_template' property specifies the current availability
  #     template for the time based booking

  def get_availability_template_object
    if model.availability_template && model.custom_availability_template?
      model.availability_template
    elsif model.availability_templates.any?
      model.availability_templates.first_or_initialize do |at|
        at.availability_rules ||= [AvailabilityRule.new]
      end
    elsif model.availability_template
      duplicate_template(model.availability_template)
    elsif model&.default_availability_template
      duplicate_template(model.default_availability_template)
    else
      model.availability_templates.new
    end
  end

  def duplicate_template(template)
    model.availability_template = template.dup
    model.availability_template.availability_rules = template.availability_rules.map(&:dup)
    model.availability_template
  end

  def availability_rules_minimum_booking_minutes
    # FIXME: the only client we have does not want it.. anyway, we might want to do it in a better way
    return true if minimum_booking_minutes.blank? || true
    availability_templates.each do |at|
      at.availability_rules.each do |ar|
        errors.add(:availability_templates, :invalid) unless ar.validate_minimum_opening_times(minimum_booking_minutes)
      end
    end
  end

  def minimum_booking_hours=(hours)
    super(hours.to_f)
    self.minimum_booking_minutes = hours.to_f * 60
  end

  def minimum_booking_hours
    super.presence || minimum_booking_minutes.to_f / 60
  end
end
