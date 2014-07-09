class InstanceAdmin::Manage::ConfidentialFilesController < InstanceAdmin::Manage::BaseController

  before_filter :find_confidential_files, only: [:index]

  def index
  end

  def edit
    @confidential_file = ConfidentialFile.find(params[:id])
  end

  def update
    params[:confidential_file] ||= {}
    @confidential_file = ConfidentialFile.find(params[:id])
    @confidential_file.comment = params[:confidential_file].delete(:comment)
    @confidential_file.state_event = params[:confidential_file].delete(:state_event)
    if @confidential_file.update_attributes(confidential_file_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.confidential_files.created'
      redirect_to instance_admin_manage_confidential_files_path
    else
      flash[:error] = @confidential_file.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  private

  def find_confidential_files
    params[:show] ||= 'uploaded'
    @confidential_files = ConfidentialFile.scoped
    @confidential_files = case params[:show]
    when "pending"
      @confidential_files.pending
    when "accepted"
      @confidential_files.accepted
    when "rejected"
      @confidential_files.rejected
    when "questioned"
      @confidential_files.questioned
    else
      @confidential_files.uploaded
    end.paginate(page: params[:page] || 1)
  end

  def confidential_file_params
    params.require(:confidential_file).permit(secured_params.confidential_file)
  end
end
