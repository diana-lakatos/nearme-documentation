# frozen_string_literal: true
class TimeBasedBookingForm < ActionTypeForm
  model "transactable/time_based_booking"

  property :type, default: 'Transactable::TimeBasedBooking'
  property :availability_template
  property :availability_template_id,
    populator: ->(fragment:, **){
      if fragment.to_i > 0
        self.availability_template_id = fragment
      else
        return skip!
      end
    }

  class << self
    def decorate(configuration)
      Class.new(self) do

        super

        if (availability_configuration = configuration.delete(:availability_templates)).present?
          validation = availability_configuration.delete(:validation)
          validates :availability_templates, validation if validation.present?
          validate do
            return true if minimum_booking_minutes.blank?
            availability_templates.each do |at|
              at.availability_rules.each do |ar|
                ar.errors.add :close_time, I18n.t('errors.messages.minimum_open_time',
                                                    minimum_hours: sprintf('%.2f', minimum_booking_hours),
                                                    count: minimum_booking_hours) if ar.opening_time < minimum_booking_minutes.to_i
              end
            end
          end
          collection :availability_templates, form: AvailabilityTemplateForm.decorate(availability_configuration),
                                prepopulator: ->(option) { self.availability_templates << get_availability_template_object if self.availability_templates.blank? },
                                populator: -> (fragment:, **) {
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
                                                      availability_templates.append(self.availability_template)
                                                    end
                                                   }
        end
      end
    end
  end

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

  def minimum_booking_hours
    minimum_booking_minutes.to_f / 60
  end
end
