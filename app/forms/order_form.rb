# frozen_string_literal: true
class OrderForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        @reservation_type = configuration[:reservation_type]
        if (reservations_configuration = configuration.delete(:reservations)).present?
          validation = reservations_configuration.delete(:validation)
          validates :reservations, validation if validation.present?
          collection :reservations, form: ReservationForm.decorate(reservations_configuration),
                                    populate_if_empty: :build_reservation_object,
                                    prepopulator: ->(_options) { reservations << build_reservation_object if reservations.size.zero? }
        end
        if (properties_configuration = configuration.delete(:properties)).present?
          validation = properties_configuration.delete(:validation)
          validates :properties, validation if validation.present?
          property :properties, form: PropertiesForm.decorate(properties_configuration)
        end
        configuration.each do |field, options|
          property :"#{field}", options[:property_options].presence || {}
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end
  end

  def build_reservation_object(*_args)
    rt = self.class.instance_variable_get(:'@reservation_type')
    model.real_model.reservations.build(
      reservation_type: rt,
      owner: model.real_model.user,
      user: model.real_model.user,
      settings: rt.settings
    )
  end
end
