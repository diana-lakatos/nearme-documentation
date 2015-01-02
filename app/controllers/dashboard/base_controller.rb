class Dashboard::BaseController < ApplicationController
  layout 'dashboard'

  before_filter :authenticate_user!
  before_filter :find_company
  before_filter :redirect_if_no_company


  private

  def find_company
    @company = current_user.companies.first
  end

  def redirect_if_no_company
    unless @company
      flash[:warning] = t('flash_messages.dashboard.add_your_company')
      redirect_to new_space_wizard_url
    end
  end

end