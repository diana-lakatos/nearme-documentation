class Admin::PagesController < Admin::ResourceController
  private

  def page_params
    params.require(:page).permit(secured_params.page)
  end
end
