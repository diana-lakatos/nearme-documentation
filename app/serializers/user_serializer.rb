# frozen_string_literal: true
class UserSerializer < ApplicationSerializer
  attributes :id, :name, :email, :phone, :avatar

  def avatar
    return {} if object.avatar.blank?
    {
      thumb_url:  object.avatar_url(:thumb).to_s,
      medium_url: object.avatar_url(:medium).to_s
    }
  end
end
