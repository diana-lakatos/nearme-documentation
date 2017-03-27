# frozen_string_literal: true
class Dashboard::GroupsController < Dashboard::BaseController
  include LinksHelper

  before_action :find_group, only: [:edit, :update, :destroy]
  before_action :can_moderate?, only: [:edit, :update, :destroy]

  def index
    @groups = current_user.group_collaborated.decorate
  end

  def new
    group_type = GroupType.find_by(name: 'Public')
    @group = current_user.groups.build(transactable_type: group_type)
    @photos = @group.gallery_photos
  end

  def create
    @group = current_user.groups.build(group_params)
    @group.draft_at = Time.now if params[:save_for_later]
    set_links_creator_id(@group)

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
    set_links_creator_id(@group)

    respond_to do |format|
      format.html do
        if @group.save
          flash[:success] = t('flash_messages.manage.groups.updated')
          redirect_to dashboard_groups_path
        else
          flash.now[:error] = t('flash_messages.product.complete_fields') + view_context.array_to_unordered_list(@group.errors.full_messages)
          @photos = @group.gallery_photos
          @group.draft_at = draft
          render :edit
        end
      end
      format.json do
        if group.save
          render json: { success: true }
        else
          render json: { errors: @group.errors.full_messages }, status: 422
        end
      end
    end
  end

  def destroy
    @group.destroy
    flash[:deleted] = t('group.group_deleted')
    redirect_to dashboard_groups_path
  end

  def video
    video_urls = params[:video_url].to_s.split(/\s*,\s*/)
    video_urls = [''] if video_urls.blank?

    video_embedders = video_urls.map { |video_url| VideoEmbedder.new(video_url) }

    if video_embedders.any?(&:valid?)
      render json: {
        html: video_embedders.map do |video_embedder|
          video_embedder.valid? ? render_to_string(partial: 'video', object: video_embedder.video_url) : ''
        end.join
      }
    else
      render json: { errors: video_embedders.find { |video_embedder| !video_embedder.valid? }.errors }, status: 422
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
