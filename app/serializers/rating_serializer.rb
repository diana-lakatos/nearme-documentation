class RatingSerializer < ActiveModel::Serializer

  attributes :content_id, :user_id

  def attributes

    hash = super

    # Included entire ratings object if referenced above
    hash.merge!(:rating => rating.rating)

    hash
  end

end
