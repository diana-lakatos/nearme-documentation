class MigrateToCalendarMonth < ActiveRecord::Migration
  def up
    Instance.where.not(id: 23).find_each do |instance|
      puts "Migrating instance #{instance.id} - #{instance.name}"
      instance.set_context!
      TransactableType.where(action_monthly_booking: true).find_each do |tt|
        next unless tt.time_based_booking
        how_many_days = tt.days_for_monthly_rate.to_i > 0 ? tt.days_for_monthly_rate.to_i : 30
        TransactableType::Pricing.
          where(action_id: tt.time_based_booking.id, action_type: tt.time_based_booking.type).
          where("(number_of_units = #{how_many_days} or number_of_units > 7) and unit in ('day')").
          update_all(number_of_units: 1, unit: "day_month")
        TransactableType::Pricing.
          where(action_id: tt.time_based_booking.id, action_type: tt.time_based_booking.type).
          where("(number_of_units = #{how_many_days} or number_of_units > 7) and unit in ('night')").
          update_all(number_of_units: 1, unit: "night_month")
      end
      Transactable::Pricing.where("number_of_units > 7 and unit = 'day' ").update_all(number_of_units: 1, unit: 'day_month')
      Transactable::Pricing.where("number_of_units > 7 and unit = 'night' ").update_all(number_of_units: 1, unit: 'night_month')
    end
  end
end
