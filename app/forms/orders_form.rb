# frozen_string_literal: true
class OrdersForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |reservation_type_name, fields|
          add_validation(reservation_type_name, fields)
          fields[:reservation_type] = find_reservation_type(reservation_type_name)
          property :"#{reservation_type_name}", form: OrderForm.decorate(fields)
        end
      end
    end

    def find_reservation_type(name)
      @name_to_reservation_type_hash ||= {}
      reservation_type = @name_to_reservation_type_hash[name] ||= ReservationType.with_parameterized_name(name)
      raise ArgumentError, "Reservation Type #{name} does not exist. Did you mean one of: #{ReservationType.pluck(:parameterized_name).join(',')} ?" if reservation_type.nil?
      reservation_type
    end
  end
end
