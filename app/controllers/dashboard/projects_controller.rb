class Dashboard::ProjectsController < Dashboard::BaseController
  before_filter :find_transactable_type
  before_filter :find_project, except: [:index, :new, :create]
  before_filter :set_form_components, only: [:new, :create, :edit, :update]

  def index
    @projects = @transactable_type.projects.joins('LEFT JOIN project_collaborators pc ON pc.project_id = projects.id').
      where('projects.creator_id = ? OR (pc.user_id = ? AND pc.approved_by_owner_at IS NOT NULL AND pc.approved_by_user_at IS NOT NULL)', current_user.id, current_user.id).
      search_by_query([:name, :description, :summary], params[:query]).
      group('projects.id').order('created_at DESC').paginate(page: params[:page], per_page: 20)
  end

  def new
    @project = @transactable_type.projects.build(creator: current_user)
    @photos = current_user.photos.where(owner_id: nil)
  end

  def create
    @project = @transactable_type.projects.build
    @project.creator = current_user
    @project.assign_attributes(project_params)
    @project.draft_at = Time.now if params[:save_for_later]
    if @project.save
      flash[:success] = t('flash_messages.manage.listings.desk_added', bookable_noun: @transactable_type.translated_bookable_noun)
      redirect_to dashboard_project_type_projects_path(@transactable_type)
    else
      flash.now[:error] = t('flash_messages.product.complete_fields') + view_context.array_to_unordered_list(@project.errors.full_messages)
      @photos = @project.photos
      render :new
    end
  end

  def show
    redirect_to action: :edit
  end

  def edit
    @photos = @project.photos
  end

  def update
    @project.assign_attributes(project_params)
    draft = @project.draft_at
    @project.draft_at = nil if params[:submit]
    respond_to do |format|
      format.html {
        if @project.save
          flash[:success] = t('flash_messages.manage.listings.listing_updated')
          redirect_to dashboard_project_type_projects_path(@transactable_type)
        else
          flash.now[:error] = t('flash_messages.product.complete_fields') + view_context.array_to_unordered_list(@project.errors.full_messages)
          @photos = @project.photos
          @project.draft_at = draft
          render :edit
        end
      }
      format.json {
        if @project.save
          render :json => { :success => true }
        else
          render :json => { :errors => @project.errors.full_messages }, :status => 422
        end
      }
    end
  end

  def destroy
    @project.destroy
    flash[:deleted] = t('flash_messages.manage.listings.listing_deleted')
    redirect_to dashboard_project_type_projects_path(@transactable_type)
  end

  private

  def set_form_components
    @form_components = @transactable_type.form_components.where(form_type: FormComponent::PROJECT_ATTRIBUTES).rank(:rank)
  end

  def find_project
    begin
      @project = @transactable_type.projects.where(creator_id: current_user.id).includes(project_collaborators: :user).find_by(id: params[:id])
      @project ||= current_user.project_collaborators.find_by!(project_id: params[:id]).try(:project)
    rescue ActiveRecord::RecordNotFound
      raise Project::NotFound
    end
  end

  def find_transactable_type
    @transactable_type = ProjectType.find(params[:project_type_id])
  end

  def project_params
    params.require(:project).permit(secured_params.project(@transactable_type, @project.nil? || current_user.id == @project.creator_id )).tap do |whitelisted|
      whitelisted[:properties] = params[:project][:properties] rescue {}
    end
  end

end
