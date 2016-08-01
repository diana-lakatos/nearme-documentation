class SetProperFcForAvailability < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      instance.set_context!
      TransactableType::TimeBasedBooking.enabled.find_each do |at|
        next unless at.transactable_type
        at.transactable_type.form_components.find_each do |fc|
          if fc.form_fields.any?{|field| field['transactable'] && field['transactable'].include?('schedule')} && fc.form_fields.none?{|field| field['transactable'] && field['transactable'].include?('availability_rules')}
            fc.form_fields << { 'transactable' => 'availability_rules' }
          end
          unless at.transactable_type.event_booking.try(:enabled)
            fc.form_fields.reject!{|field| field['transactable'] && field['transactable'].include?('schedule')}
          end
          fc.save!
        end
      end
    end
  end
end
