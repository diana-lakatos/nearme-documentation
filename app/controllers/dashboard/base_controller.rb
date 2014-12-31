class Dashboard::BaseController < ApplicationController
  layout 'dashboard'

  before_filter :authenticate_user!
  before_filter :set_company

  private

  def set_company
    @company = current_user.companies.first
  end
end