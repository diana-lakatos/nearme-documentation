class SubscribesController < ApplicationController
  skip_before_action :redirect_unverified_user, only: [:edit, :update]
  skip_before_action :authenticate_user!, only: [:edit, :update]

  def edit
  end

  def update
    user = User.find_by email: params[:user][:email]

    if user.present?
      InstanceMailer.mail(to: user.email, from: PlatformContext.current.theme.contact_email_with_fallback,
        subject: t('flash_messages.unsubscribe.email_subject'), template_name: 'user_mailer/unsubscribe',
        layout_path: 'layouts/mailer').deliver_now
    end

    redirect_to root_path, flash: { success: t('flash_messages.unsubscribe.email_sent') }
  end
end
