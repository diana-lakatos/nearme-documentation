class ProjectTypes::ProjectWizardController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_project_type
  before_filter :redirect_to_dashboard_if_registration_completed, only: [:new]
  before_filter :set_common_variables, only: [:new, :create]
  before_filter :set_form_components

  layout :dashboard_or_community_layout

  def new
    @photos = (@user.projects.first.try(:photos) || []) + @user.photos.where(owner_id: nil)
    @user.projects.build unless @user.projects.first
  end

  def create
    @user.assign_attributes(wizard_params)
    if @user.save
      flash[:success] = t('flash_messages.space_wizard.space_listed', bookable_noun: @transactable_type.name)
      redirect_to dashboard_project_type_projects_path(@transactable_type)
    else
      @photos = @user.projects.first.try(:photos)
      flash.now[:error] = t('flash_messages.space_wizard.complete_fields') + view_context.array_to_unordered_list(@user.errors.full_messages)
      render :new
    end
  end

  private

  def find_project_type
    @transactable_type = ProjectType.includes(:custom_attributes).find(params[:project_type_id])
  end

  def set_form_components
    @form_components = @transactable_type.form_components.where(form_type: FormComponent::SPACE_WIZARD).rank(:rank)
  end

  def set_common_variables
    @user = User.includes(:projects).find(current_user.id)
    @country = if params[:user] && params[:user][:country_name]
                 params[:user][:country_name]
               elsif @user.country_name.present?
                 @user.country_name
               else
                 request.location.country rescue nil
               end
  end

  def redirect_to_dashboard_if_registration_completed
    if current_user.try(:registration_completed?)
      redirect_to dashboard_project_type_projects_path(@transactable_type)
    end
  end

  def wizard_params
    params.require(:user).permit(secured_params.user(transactable_type: @transactable_type))
  end

  def can_delete_photo?(photo, user)
    return true if photo.creator == user                         # if the user created the photo
  end
end
