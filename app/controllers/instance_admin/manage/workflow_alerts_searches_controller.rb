# frozen_string_literal: true
class InstanceAdmin::Manage::WorkflowAlertsSearchesController < InstanceAdmin::Manage::BaseController
  before_action :set_breadcrumbs_title

  def show
    scope_search_form = InstanceAdmin::WorkflowAlertsSearchForm.new
    scope_search_form.validate(params)

    @workflow_alerts = SearchService.new(WorkflowAlert.where(nil)).search(scope_search_form.to_search_params)
                       .paginate(page: params[:page], per_page: reports_per_page)
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { title: t('instance_admin.workflows.manage_workflows'), url: instance_admin_manage_workflows_path },
      title: t('instance_admin.workflows.workflow_alerts_results')
    )
  end
end
