# frozen_string_literal: true
module Api
  module V4
    class UsersController < Api::V4::BaseController
      skip_before_action :require_authentication, except: [:edit, :update, :destroy]
      skip_before_action :require_authorization
      skip_before_action :redirect_unverified_user, only: [:verify]
      before_action :find_user, only: [:verify]
      before_action :set_return_to, only: :new

      def new
        user_signup.prepopulate!
      end

      def create
        SubmitForm.new(form_configuration: form_configuration,
                       form: user_signup, params: form_params,
                       current_user: current_user).tap do |submit_form|
          submit_form.add_success_observer(SubmitForm::IndexInElastic.new)
          submit_form.add_success_observer(SubmitForm::SignIn.new(self))
        end.call
        respond(user_signup, notice: I18n.t('devise.registrations.signed_up'),
                             location: return_to_path)
      end

      def update
        SubmitForm.new(
          form_configuration: form_configuration,
          form: user_update_form,
          params: form_params,
          current_user: current_user
        ).tap do |submit_form|
          submit_form.add_success_observer(SubmitForm::LegacyMarkAsOnboarded.new)
          submit_form.add_success_observer(SubmitForm::ChangeLocale.new)
        end.call
        respond(user_update_form)
      end

      def verify
        SubmitForm.new(
          form_configuration: form_configuration,
          form: verification_form,
          params: params,
          current_user: current_user
        ).tap do |submit_form|
          submit_form.add_success_observer(SubmitForm::SignIn.new(self))
          submit_form.add_success_observer(SubmitForm::LegacySetFlashMessage.new(
                                             self, :success, t('flash_messages.registrations.address_verified')
          ))
          submit_form.add_failure_observer(SubmitForm::LegacyDisplayValidationErrors.new(self))
        end.call
        if verification_form.valid?
          redirect_to root_path
        else
          respond(verification_form)
        end
      end

      protected

      def form_params
        params[:form].presence || params[:user] || {}
      end

      def user_signup
        @user_signup ||= form_configuration&.build(new_user) ||
                         FormBuilder::UserSignupBuilderFactory.builder(params[:role]).build(new_user)
      end

      def user_update_form
        @user_update_form ||= form_configuration&.build(current_user)
      end

      def new_user
        ::User.new_with_session({}, session)
      end

      def verification_form
        @verification_form ||= UserVerificationForm.new(@user, verified_at: @user.verified_at)
      end

      def find_user
        @user = ::User.find(params[:id])
      end

      def set_return_to
        disallowed_regex = /(users\/sign_in|users\/password)/
        if params[:return_to].present? && !params[:return_to].to_s.match(disallowed_regex)
          session[:user_return_to] = params[:return_to]
        end
      end

      def return_to_path
        session.delete(:user_return_to).presence || params[:return_to].presence || root_path
      end
    end
  end
end
