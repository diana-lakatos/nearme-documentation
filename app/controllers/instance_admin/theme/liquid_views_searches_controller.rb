# frozen_string_literal: true
class InstanceAdmin::Theme::LiquidViewsSearchesController < InstanceAdmin::Theme::BaseController
  before_action :set_breadcrumbs_title

  def show
    scope_search_form = InstanceAdmin::LiquidViewsSearchForm.new
    scope_search_form.validate(params)

    @liquid_views = SearchService.new(platform_context.instance.instance_views.liquid_views).search(scope_search_form.to_search_params)
                    .paginate(page: params[:page], per_page: reports_per_page)
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { title: t('instance_admin.liquid_views.liquid_views'), url: instance_admin_theme_liquid_views_path },
      title: t('instance_admin.liquid_views.liquid_views_results')
    )
  end
end
