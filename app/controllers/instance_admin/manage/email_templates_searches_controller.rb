# frozen_string_literal: true
class InstanceAdmin::Manage::EmailTemplatesSearchesController < InstanceAdmin::Manage::BaseController
  before_action :set_breadcrumbs_title

  def show
    scope_search_form = InstanceAdmin::EmailTemplatesSearchForm.new
    scope_search_form.validate(params)

    @email_templates = SearchService.new(platform_context.instance.instance_views.custom_emails).search(scope_search_form.to_search_params)
                       .paginate(page: params[:page], per_page: reports_per_page)
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { title: t('instance_admin.manage.email_templates.email_templates'), url: instance_admin_manage_email_templates_path },
      title: t('instance_admin.manage.email_templates.email_templates_results')
    )
  end
end
