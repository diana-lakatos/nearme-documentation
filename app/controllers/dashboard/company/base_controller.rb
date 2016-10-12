class Dashboard::Company::BaseController < Dashboard::BaseController
  before_filter :authenticate_user!
  before_filter :redirect_unless_registration_completed
  before_filter :find_company

  private

  def find_company
    @company = current_user.try(:companies).try(:first).try(:decorate)
  end

  def redirect_unless_registration_completed
    unless current_user.registration_completed?
      flash[:warning] = t('flash_messages.dashboard.add_your_company')
      redirect_to transactable_type_new_space_wizard_path(TransactableType.first)
    end
  end
end
