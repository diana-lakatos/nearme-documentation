class Dashboard::BaseController < ApplicationController
  layout 'dashboard'

  before_filter :authenticate_user!
  before_filter :find_company


  private

  def find_company
    @company = current_user.try(:companies).try(:first).try(:decorate)
  end
end
