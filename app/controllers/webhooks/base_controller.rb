# frozen_string_literal: true
class Webhooks::BaseController < ActionController::Base
  before_action :set_raygun_custom_data

  def test
    render text: "json: #{params.inspect}"
  end

  def set_raygun_custom_data
    return if Rails.application.config.silence_raygun_notification
    begin
      Raygun.configuration.custom_data = {
        platform_context: PlatformContext.current.to_h,
        request_params: params.reject { |k, _v| Rails.application.config.filter_parameters.include?(k.to_sym) },
        process_pid: Process.pid,
        process_ppid: Process.ppid,
        git_version: Rails.application.config.git_version
      }
    rescue => e
      Rails.logger.debug "Error when preparing Raygun custom_params: #{e}"
    end
  end
end
