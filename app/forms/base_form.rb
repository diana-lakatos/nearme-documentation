# frozen_string_literal: true
class BaseForm < Reform::Form
  class << self
    def reflect_on_association(*_args)
      nil
    end
  end

  def to_liquid
    @form_builder_drop ||= FormDrop.new(self)
  end

  def new_record?
    model.new_record?
  end

  def marked_for_destruction?
    model.marked_for_destruction?
  end

  # Ideally this method should not exist, forms should be clever enough to use translations automatically
  # Not that simple though:
  # see for example @user_update_profile_form.class.human_attribute_name(:'buyer_profile.properties.driver_category')
  # on localdriva.
  # One idea is to create translations for each custom attribute etc and then `full_messages` will be working properly.
  # In current form there will be conflicts though + we would need translations for all built in attributes as well.
  # Hence, tmp hack.
  def pretty_errors_string(separator: "\n")
    ErrorsSummary.new(self).summary(separator: separator)
  end
end
