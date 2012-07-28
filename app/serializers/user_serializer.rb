class UserSerializer < ApplicationSerializer

  attributes :id, :name, :email, :phone, :avatar

  def avatar
    return {} if object.avatar.blank?
    {
      thumb_url:  "#{object.avatar_url(:thumb)}",
      medium_url: "#{object.avatar_url(:medium)}",
      large_url:  "#{object.avatar_url(:large)}"
    }
  end

end
