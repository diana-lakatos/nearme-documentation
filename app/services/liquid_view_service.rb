# frozen_string_literal: true
class LiquidViewService
  def create(template_params)
    @liquid_view = build_new_liquid_view(template_params)
    @liquid_view.save if liquid_valid?
    @liquid_view
  end

  def update(liquid_view, template_params)
    @liquid_view = liquid_view
    assign_attributes_without_path template_params

    @liquid_view.save if liquid_valid?
    @liquid_view
  end

  private

  def build_new_liquid_view(params)
    params.merge! format: 'html', handler: 'liquid', view_type: InstanceView::VIEW_VIEW
    PlatformContext.current.instance.instance_views.build(params)
  end

  def assign_attributes_without_path(params)
    @liquid_view.assign_attributes params.except(:path)
  end

  def liquid_valid?
    @liquid_view.validate
    @liquid_view.errors.empty?
  end
end
