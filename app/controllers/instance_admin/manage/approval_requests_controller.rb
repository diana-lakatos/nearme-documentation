class InstanceAdmin::Manage::ApprovalRequestsController < InstanceAdmin::Manage::BaseController

  before_filter :find_approval_request, only: [:index]
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
    @approval_requests = ApprovalRequest.all
    @approval_requests = case params[:show]
    when "approved"
      @approval_requests.approved
    when "rejected"
      @approval_requests.rejected
    when "questioned"
      @approval_requests.questioned
    else
      @approval_requests.pending
    end.paginate(page: params[:page] || 1)
  end

  def approval_request_params
    params.require(:approval_request).permit(secured_params.admin_approval_request)
  end

  def set_section_name
    @section_name = 'vendor-approval'
  end
end
