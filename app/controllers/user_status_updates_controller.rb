# frozen_string_literal: true
class UserStatusUpdatesController < ApplicationController
  def create
    current_user.user_status_updates.create(permitted_params)
    redirect_to request.referer
  end

  def update
    @user_status_update = UserStatusUpdate.find(params[:id])
    return render nothing: true unless @user_status_update.can_edit?(current_user)
    @user_status_update.update(permitted_params)
    respond_to do |format|
      format.js
      format.html
    end
  end

  def destroy
    @user_status_update = UserStatusUpdate.find(params[:id])
    return render nothing: true unless @user_status_update.can_remove?(current_user) && @user_status_update.destroy
  end

  private

  def permitted_params
    fix_multiple_images(params[:user_status_update]).permit!
  end

  def fix_multiple_images(user_status_params)
    if user_status_params["activity_feed_images_attributes"]
      feed_images = user_status_params["activity_feed_images_attributes"].dup
      feed_images.each_pair do |image_idx, afi|
        if afi["image"].present? && afi["id"].nil?
          afi["image"].each_with_index do |img, file_idx|
            idx = image_idx.to_i + file_idx
            user_status_params["activity_feed_images_attributes"][idx.to_s] ||= {}
            user_status_params["activity_feed_images_attributes"][idx.to_s]["image"] = img
          end
        end
      end
    end
    user_status_params
  end
end
