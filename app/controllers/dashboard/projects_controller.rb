class Dashboard::ProjectsController < Dashboard::BaseController
  before_filter :find_transactable_type
  before_filter :find_transactable, except: [:index, :new, :create]
  before_filter :set_form_components, only: [:new, :create, :edit, :update]

  def index
    @transactables = @transactable_type.transactables.joins('LEFT JOIN transactable_collaborators pc ON pc.transactable_id = transactables.id').
      where('transactables.creator_id = ? OR (pc.user_id = ? AND pc.approved_by_owner_at IS NOT NULL AND pc.approved_by_user_at IS NOT NULL)', current_user.id, current_user.id).
      search_by_query([:name, :description, :summary], params[:query]).
      group('transactables.id').order('created_at DESC').paginate(page: params[:page], per_page: 20)
  end

  def new
    @transactable = @transactable_type.transactables.build(creator: current_user)
    @photos = current_user.photos.where(owner_id: nil)
  end

  def create
    @transactable = @transactable_type.transactables.build
    @transactable.creator = current_user
    @transactable.assign_attributes(transactable_params)
    @transactable.draft_at = Time.now if params[:save_for_later]
    @transactable.location_not_required = true
    @transactable.build_action_type
    @transactable.action_type.transactable_type_action_type = @transactable_type.action_types.first
    @transactable.topics_required = true

    if @transactable.save
      flash[:success] = t('flash_messages.manage.listings.desk_added', bookable_noun: @transactable_type.translated_bookable_noun)
      redirect_to dashboard_project_type_projects_path(@transactable_type)
    else
      flash.now[:error] = t('flash_messages.product.complete_fields') + view_context.array_to_unordered_list(@transactable.errors.full_messages)
      @photos = @transactable.photos
      render :new
    end
  end

  def show
    redirect_to action: :edit
  end

  def edit
    @photos = @transactable.photos
  end

  def update
    @transactable.assign_attributes(transactable_params)
    @transactable.location_not_required = true
    @transactable.topics_required = true
    draft = @transactable.draft
    @transactable.draft = nil if params[:submit]
    respond_to do |format|
      format.html {
        if @transactable.save
          flash[:success] = t('flash_messages.manage.listings.listing_updated')
          redirect_to dashboard_project_type_projects_path(@transactable_type)
        else
          flash.now[:error] = t('flash_messages.product.complete_fields') + view_context.array_to_unordered_list(@transactable.errors.full_messages)
          @photos = @transactable.photos
          @transactable.draft = draft
          render :edit
        end
      }
      format.json {
        if @transactable.save
          render :json => { :success => true }
        else
          render :json => { :errors => @transactable.errors.full_messages }, :status => 422
        end
      }
    end
  end

  def destroy
    @transactable.destroy
    flash[:deleted] = t('flash_messages.manage.listings.listing_deleted')
    redirect_to dashboard_project_type_projects_path(@transactable_type)
  end

  private

  def set_form_components
    @form_components = @transactable_type.form_components.where(form_type: FormComponent::TRANSACTABLE_ATTRIBUTES).rank(:rank)
  end

  def find_transactable
    begin
      @transactable = @transactable_type.transactables.where(creator_id: current_user.id).includes(transactable_collaborators: :user).find(params[:id])
      @transactable ||= current_user.transactable_collaborators.find_by!(transactable_id: params[:id]).try(:transactable)
    rescue ActiveRecord::RecordNotFound
      raise Project::NotFound
    end
  end

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:project_type_id])
  end

  def transactable_params
    params.require(:transactable).permit(secured_params.project(@transactable_type, @transactable.nil? || current_user.id == @transactable.creator_id )).tap do |whitelisted|
      whitelisted[:properties] = params[:transactable][:properties] rescue {}
    end
  end

end
