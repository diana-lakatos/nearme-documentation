class InstanceAdmin::Settings::TransactableTypes::TransactableTypeAttributesController < InstanceAdmin::Manage::BaseController
  inherit_resources
  belongs_to :project

  private

  def permitting_controller_class
    'settings'
  end

end
