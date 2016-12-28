# frozen_string_literal: true
class Admin::Assets::GeneralSettingsController < Admin::Assets::BaseController
  def edit
  end

  def update
    if @transactable_type.save
      flash[:success] = t 'admin.transactable_type.flash_message.updated'

      if request.xhr?
        render json: { result: 'success', data: { redirect: admin_assets_general_settings_path(@transactable_type) } }
      else
        redirect_to admin_assets_general_settings_path(@transactable_type)
      end
    else
      if request.xhr?
        render json: { result: 'fail', data: @transactable_type.errors }
      else
        flash.now[:error] = @transactable_type.errors.full_messages.to_sentence
        render action: :edit
      end
    end
  end
end
