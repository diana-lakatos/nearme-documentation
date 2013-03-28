module SpaceWizardHelper
  def space_wizard_step_class(step_number, current_step)
    if current_step > step_number
      'complete ico-check padding'
    elsif current_step == step_number
      'current'
    else
      ''
    end
  end
end
