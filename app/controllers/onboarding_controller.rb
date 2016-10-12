class OnboardingController < ApplicationController
  include Wicked::Wizard

  before_filter :redirect_if_completed

  steps :location, :integrations, :followings, :finish

  def show
    @user = current_user
    set_variables_for_step(step)
    render_wizard
  end

  def update
    @user = current_user

    set_variables_for_step(step)

    case step
    when :location
      @address.update_attributes(address_params)
      render_wizard @address
    when :integrations
      render_wizard @user
    when :followings
      @user.feed_followed_users << User.where(id: followed_params[:people]).feed_not_followed_by_user(@user) if followed_params[:people]
      @user.feed_followed_transactables << Transactable.active.where(id: followed_params[:projects]).feed_not_followed_by_user(@user) if followed_params[:projects]
      @user.feed_followed_topics << Topic.where(id: followed_params[:topics]).feed_not_followed_by_user(@user) if followed_params[:topics]
      render_wizard @user
    when :finish
      @user.update_attributes(user_params)
      render_wizard @user
    else
      fail NotImplementedError
    end
  end

  def finish_wizard_path
    current_user.update_attribute(:onboarding_completed, true)
    root_path
  end

  private

  # To be DRY, extracted the variable setup to this method
  # We need them both for show and for update (update renders the same step if the object fails to save)
  def set_variables_for_step(step)
    case step
    when :location
      @address = @user.current_address || @user.build_current_address
    when :integrations
      cookies[:redirect_after_callback_to] = { value: view_context.wizard_path(step), expires: 10.minutes.from_now }
      @supported_providers = Authentication.available_providers
    when :followings
      quantity = 6
      @topics = Topic.featured.feed_not_followed_by_user(@user).take(quantity)

      friends_projects = Transactable.active.where(creator_id: @user.social_friends_ids).feed_not_followed_by_user(@user).take(quantity)
      featured_projects = Transactable.active.featured.feed_not_followed_by_user(@user).take(quantity - friends_projects.count)
      @projects = friends_projects + featured_projects

      friends = @user.social_friends.not_admin.feed_not_followed_by_user(@user).take(quantity)
      # We do not use the feed_not_followed_by_user scope because it doesn't play well
      # with the nearby_friends filter
      nearby =  @user.nearby_friends(100, @user.feed_followed_users.pluck(:id)).not_admin.take(quantity - friends.count)
      featured = User.not_admin.featured.without(@user).feed_not_followed_by_user(@user).take(quantity - friends.count - nearby.count)
      @people = (friends + nearby + featured).uniq
    when :finish
      @custom_attributes = []
      @custom_attributes = @user.instance_profile_type.custom_attributes.includes(:target).where(public: true).all if @user.instance_profile_type.present?
    end
  end

  def user_params
    params.require(:user).permit(secured_params.user).tap do |whitelisted|
      whitelisted[:properties] = params[:user][:properties] if params[:user][:properties]
    end
  end

  def address_params
    params.require(:address).permit(secured_params.address)
  end

  def followed_params
    params.require(:followed).permit(people: [], projects: [], topics: [])
  end

  def redirect_if_completed
    redirect_to root_path if !user_signed_in? || current_user.onboarding_completed
  end
end
