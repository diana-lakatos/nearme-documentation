class InstanceAdmin::Settings::TransactableTypes::CustomAttributesController < InstanceAdmin::Settings::BaseController
  inherit_resources
  belongs_to :project

  private

  def permitting_controller_class
    'settings'
  end
end
