# frozen_string_literal: true
class UserSerializer < ApplicationSerializer
  attributes :id, :name, :email, :phone, :avatar

  def avatar
    return {} if object.avatar.blank?
    {
      thumb_url:  object.avatar.url(:thumb),
      medium_url: object.avatar.url(:medium)
    }
  end
end
