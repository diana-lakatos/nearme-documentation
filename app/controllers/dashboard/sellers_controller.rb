# frozen_string_literal: true
class Dashboard::SellersController < Dashboard::BaseController
  before_action :set_seller_profile
  before_action :set_form_components, only: [:edit, :update]
  skip_before_action :force_fill_in_wizard_form
  before_action :build_user_update_profile_form, only: [:edit, :update]

  def edit
    @user_update_profile_form.prepopulate!
  end

  def update
    if @user_update_profile_form.validate(params[:user] || params[:form] || {})
      @user_update_profile_form.save
      current_user.reload.seller_profile.mark_as_onboarded!
      flash.now[:success] = t('flash_messages.dashboard.seller.updated')
      if session[:after_onboarding_path].present?
        redirect_to session[:after_onboarding_path]
        session[:after_onboarding_path] = nil
      else
        redirect_to edit_dashboard_seller_path
      end
    else
      flash.now[:error] = @user_update_profile_form.pretty_errors_string
      @user_update_profile_form.prepopulate!
      render :edit, layout: dashboard_or_community_layout
    end
  end

  protected

  def set_seller_profile
    @seller_profile = current_user.seller_profile
    redirect_to edit_registration_path(current_user) unless @seller_profile.present? && current_instance.seller_profile_enabled?
  end

  def set_form_components
    @form_components = PlatformContext.current.instance.seller_profile_type.form_components.where(form_type: FormComponent::SELLER_PROFILE_TYPES).rank(:rank)
  end

  def user_params
    params.require(:user).permit(secured_params.user)
  end

  def build_user_update_profile_form
    @form_configuration = FormConfiguration.find_by(id: params[:form_configuration_id])
    @user_update_profile_form = @form_configuration&.build(current_user) || FormConfiguration.where(base_form: 'UserUpdateProfileForm', name: 'lister_update').first.build(current_user)
  end
end
