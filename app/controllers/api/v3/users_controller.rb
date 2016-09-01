module Api
  class V3::UsersController < BaseController
    skip_before_filter :require_authentication, only: [:create, :show]
    skip_before_filter :require_authorization
    before_filter :find_user, only: [:show]

    def create
      params[:user] ||= {}
      params[:role] ||= 'buyer' if current_instance.split_registration?
      @role = %w(seller buyer).detect { |r| r == params[:role] }
      @role ||= "default"
      params[:user][:force_profile] = @role
      @user = User.new(user_params)
      @user.custom_validation = true

      if @user.save
        event_tracker.signed_up(@user, {
          referrer_id: PlatformContext.current.platform_context_detail.id,
          referrer_type: PlatformContext.current.platform_context_detail.class.to_s,
          signed_up_via: 'api'
        })
        sign_in(@user)
        ReengagementNoBookingsJob.perform_later(72.hours.from_now, @user.id)
        case @role
        when 'default'
          WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::AccountCreated, @user.id)
        when 'seller'
          WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::ListerAccountCreated, @user.id)
        when 'buyer'
          WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::EnquirerAccountCreated, @user.id)
        end
        render json: ApiSerializer.serialize_object(@user)
      else
        render json: ApiSerializer.serialize_errors(@user.errors)
      end
    end

    def show
      render json: ApiSerializer.serialize_object(@user)
    end

    protected

    def find_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(secured_params.user).tap do |whitelisted|
        whitelisted[:sms_preferences] = params[:user][:sms_preferences] if params[:user][:sms_preferences]
        whitelisted[:properties] = params[:user][:properties] if params[:user][:properties]
      end
    end
  end
end

