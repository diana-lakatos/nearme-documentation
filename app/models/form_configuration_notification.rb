# frozen_string_literal: true
class FormConfigurationNotification < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  belongs_to :form_configuration, touch: true
  belongs_to :notification, polymorphic: true, touch: true
end
