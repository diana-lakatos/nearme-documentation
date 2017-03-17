# frozen_string_literal: true
class InstanceAdmin::Manage::ApprovalRequestsController < InstanceAdmin::Manage::BaseController
  before_action :find_approval_request, only: [:index]
  before_action :set_section_name

  def index
  end

  def edit
    @approval_request = ApprovalRequest.find(params[:id])
  end

  def update
    params[:approval_request] ||= {}
    @approval_request = ApprovalRequest.find(params[:id])
    if @approval_request.update_attributes(approval_request_params)
      if @approval_request.approved?
        case @approval_request.owner
        when User
          WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::Approved, @approval_request.owner_id, as: current_user)
        when Transactable
          WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::Approved, @approval_request.owner_id, as: current_user)
        end
      end
      flash[:success] = t 'flash_messages.instance_admin.manage.approval_request.updated'
      redirect_to instance_admin_manage_approval_requests_path
    else
      flash[:error] = @approval_request.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  private

  def find_approval_request
    params[:show] ||= 'pending'
    @approval_request_search_form = InstanceAdmin::ApprovalRequestSearchForm.new
    @approval_request_search_form.validate(params)
    @approval_requests = SearchService.new(ApprovalRequest.for_non_drafts.order('created_at DESC')).search(@approval_request_search_form.to_search_params).paginate(page: params[:page])
  end

  def approval_request_params
    params.require(:approval_request).permit(secured_params.admin_approval_request)
  end

  def set_section_name
    @section_name = 'vendor-approval'
  end
end
