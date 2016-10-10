class InstanceAdmin::Manage::ApprovalRequestTemplatesController < InstanceAdmin::Manage::BaseController
  before_action :check_for_owner_type, only: [:new]
  before_action :check_if_exists, only: [:new, :create]
  before_action :set_section_name

  def index
    @approval_request_templates = []
    ApprovalRequestTemplate::OWNER_TYPES.each do |owner_type|
      @approval_request_templates << (ApprovalRequestTemplate.for(owner_type).first.presence || ApprovalRequestTemplate.new(owner_type: owner_type))
    end
  end

  def new
    @approval_request_template = ApprovalRequestTemplate.new(owner_type: @owner_type)
  end

  def create
    @approval_request_template = ApprovalRequestTemplate.new(approval_request_template_params)
    @approval_request_template_creation = ApprovalRequestTemplateCreation.new(@approval_request_template)
    if @approval_request_template_creation.create
      flash[:success] = t('flash_messages.instance_admin.manage.approval_request_templates.created')
      redirect_to instance_admin_manage_approval_request_templates_path
    else
      render :new
    end
  end

  def edit
    @approval_request_template = ApprovalRequestTemplate.find(params[:id])
  end

  def update
    @approval_request_template = ApprovalRequestTemplate.find(params[:id])
    if @approval_request_template.update_attributes(approval_request_template_params)
      flash[:success] = t('flash_messages.instance_admin.manage.approval_request_templates.updated')
      redirect_to instance_admin_manage_approval_request_templates_path
    else
      flash.now[:error] = @approval_request_template.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @approval_request_template = ApprovalRequestTemplate.find(params[:id])
    @approval_request_template.destroy
    flash[:deleted] = t('flash_messages.instance_admin.manage.approval_request_templates.deleted')
    redirect_to instance_admin_manage_approval_request_templates_path
  end

  private

  def check_for_owner_type
    if ApprovalRequestTemplate::OWNER_TYPES.include?(params[:owner_type])
      @owner_type = params[:owner_type]
    else
      flash[:error] = "ApprovalRequestTemplate has to be assigned to one of the following: #{ApprovalRequestTemplate::OWNER_TYPES.join(', ')}"
      redirect_to instance_admin_manage_approval_request_templates_path
    end
  end

  def check_if_exists
    if (approval_request_template = ApprovalRequestTemplate.for(@owner_type).first).present?
      flash[:error] = "Approval Request Template for #{@owner_type} already exists"
      redirect_to edit_instance_admin_manage_approval_request_template_path(approval_request_template)
    end
  end

  def approval_request_template_params
    params.require(:approval_request_template).permit(secured_params.approval_request_template)
  end

  def set_section_name
    @section_name = 'vendor-approval'
  end
end
