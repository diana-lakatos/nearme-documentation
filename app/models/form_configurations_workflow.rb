# frozen_string_literal: true
class FormConfigurationsWorkflow < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :form_configuration
  belongs_to :workflow_step
end
