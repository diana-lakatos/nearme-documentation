# frozen_string_literal: true
module RaygunExceptions
  extend ActiveSupport::Concern
  included do
    before_action :set_raygun_custom_data

    protected

    def set_raygun_custom_data
      return if Rails.application.config.silence_raygun_notification
      begin
        Raygun.configuration.custom_data = {
          platform_context: PlatformContext.current.to_h,
          current_user_id: current_user.try(:id),
          process_pid: Process.pid,
          process_ppid: Process.ppid,
          git_version: Rails.application.config.git_version
        }
      rescue => e
        Rails.logger.debug "Error when preparing Raygun custom_params: #{e}"
      end
    end
  end
end
