# frozen_string_literal: true
class GlobalAdmin::PagesController < GlobalAdmin::ResourceController
  private

  def page_params
    params.require(:page).permit(secured_params.page)
  end
end
