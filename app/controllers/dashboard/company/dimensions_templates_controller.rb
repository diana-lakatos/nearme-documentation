# TODO: destroy
class Dashboard::Company::DimensionsTemplatesController < Dashboard::Company::BaseController
  skip_before_filter :redirect_unless_registration_completed

  def new
    @dimensions_template = current_user.dimensions_templates.build
    @dimensions_template.creator_id = current_user.id
    render partial: 'form'
  end

  def create
    @dimensions_template = current_user.dimensions_templates.build(template_params)
    @dimensions_template.creator = current_user
    @dimensions_template.entity_id = current_user.id
    @dimensions_template.entity_type = 'User'

    render partial: 'form' unless @dimensions_template.save
  end

  private

  def template_params
    params.require(:dimensions_template).permit(secured_params.dimensions_template)
  end
end
