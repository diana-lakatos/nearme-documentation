# frozen_string_literal: true
class Admin::UiSettingsController < Admin::BaseController
  def index
    render json: { result: 'success', data: current_user.get_all_ui_settings }
  end

  def get
    render json: { result: 'success', data: current_user.get_ui_setting(params[:id]) }
  end

  def set
    if current_user.set_ui_setting(params[:id], params[:value])
      render json: { result: 'success', data: current_user.get_all_ui_settings }
    else
      render json: { result: 'error', data: 'Unable to save ui setting' }
    end
  end
end
