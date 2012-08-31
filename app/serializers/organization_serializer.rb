class OrganizationSerializer < ActiveModel::Serializer

  attributes :id, :name, :icon

  def icon
    {
      thumb_url:  object.logo_url(:thumb),
      medium_url: object.logo_url(:medium),
      large_url:  object.logo_url(:large)
    }
  end

end