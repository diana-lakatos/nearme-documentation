class Admin::PartnersController < Admin::ResourceController
  belongs_to :instance, parent_class: Instance

  def partner_params
    params.require(:partner).permit(secured_params.partner)
  end
end
