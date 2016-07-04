#TODO to be removed
class ServiceType < TransactableType

  validate :availability_options_are_correct
  validate do
    unless all_action_types.any?(&:enabled) || action_types.any?(&:enabled)
      errors.add(:base, I18n.t('errors.messages.transactable_type_actions_blank'))
    end
  end

  def availability_options_are_correct
    errors.add("availability_options[confirm_reservations][public]", "must be set") if availability_options["confirm_reservations"]["public"].nil?
    errors.add("availability_options[confirm_reservations][default_value]", "must be set") if availability_options["confirm_reservations"]["default_value"].nil?
  rescue
    errors.add("availability_options[confirm_reservations][public]", "must be set")
    errors.add("availability_options[confirm_reservations][default_value]", "must be set")
  end

end
