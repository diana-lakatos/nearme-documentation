class Dashboard::GroupsController < Dashboard::BaseController

  before_filter :find_group, only: [:edit, :update, :destroy]
  before_filter :can_moderate?, only: [:edit, :update, :destroy]

  def index
    @groups = current_user.moderated_groups
  end

  def new
    group_type = GroupType.find_by(name: 'Public')
    @group = current_user.groups.build(transactable_type: group_type)
    @photos = @group.gallery_photos
  end

  def create
    @group = current_user.groups.build(group_params)
    @group.draft_at = Time.now if params[:save_for_later]

    if @group.save
      @group.memberships.create(user: current_user, email: current_user.email, moderator: true, approved_by_user_at: Time.now, approved_by_owner_at: Time.now)
      flash[:success] = t('flash_messages.manage.groups.added', bookable_noun: @group.transactable_type.translated_bookable_noun)
      redirect_to dashboard_groups_path
    else
      flash.now[:error] = t('flash_messages.product.complete_fields') + view_context.array_to_unordered_list(@group.errors.full_messages)
      @photos = @group.photos - [@group.cover_photo]
      render :new
    end
  end

  def edit
    @photos = @group.gallery_photos
  end

  def update
    @group.assign_attributes(group_params)
    draft = @group.draft_at
    @group.draft_at = nil if params[:submit]

    respond_to do |format|
      format.html {
        if @group.save
          flash[:success] = t('flash_messages.manage.listings.listing_updated')
          redirect_to dashboard_groups_path
        else
          flash.now[:error] = t('flash_messages.product.complete_fields') + view_context.array_to_unordered_list(@group.errors.full_messages)
          @photos = @group.gallery_photos
          @group.draft_at = draft
          render :edit
        end
      }
      format.json {
        if group.save
          render :json => { :success => true }
        else
          render :json => { :errors => @group.errors.full_messages }, :status => 422
        end
      }
    end
  end

  def destroy
    @group.destroy
    flash[:deleted] = t('group.group_deleted')
    redirect_to dashboard_groups_path
  end

  def video
    video_embedder = VideoEmbedder.new(params[:video_url])

    if video_embedder.valid?
      render json: {
        html: render_to_string(partial: 'video', object: video_embedder.video_url)
      }
    else
      render json: { errors: video_embedder.errors }, status: 422
    end
  end

  private

  def find_group
    @group = Group.find(params[:id]).try(:decorate)
  end

  def can_moderate?
    unless current_user.moderated_groups.exists?(id: @group.id)
      redirect_to dashboard_groups_path, notice: t('flash_messages.authorizations.not_authorized')
    end
  end

  def group_params
    params.require(:group).permit(secured_params.group)
  end

end
