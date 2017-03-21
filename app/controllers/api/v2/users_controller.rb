# frozen_string_literal: true
module Api
  class V2::UsersController < BaseController
    skip_before_action :require_authentication, only: [:create, :show]
    skip_before_action :require_authorization, only: [:create, :show]
    before_action :find_user, only: [:show]

    def create
      params[:user] ||= {}
      params[:role] ||= 'buyer' if current_instance.split_registration?
      @role = %w(seller buyer).detect { |r| r == params[:role] }
      @role ||= 'default'
      params[:user][:force_profile] = @role
      @user = User.new(user_params)
      @user.custom_validation = true

      if @user.save
        case @role
        when 'default'
          WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::AccountCreated, @user.id, as: current_user)
        when 'seller'
          WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::ListerAccountCreated, @user.id, as: current_user)
        when 'buyer'
          WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::EnquirerAccountCreated, @user.id, as: current_user)
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
