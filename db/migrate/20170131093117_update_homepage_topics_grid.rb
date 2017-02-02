# frozen_string_literal: true
class UpdateHomepageTopicsGrid < ActiveRecord::Migration
  def up
    # hallmark
    i = Instance.find_by(id: 5011)
    # this will work only on oregon
    return unless i
    i.set_context!

    query = i.graph_queries.find_by(name: 'hallmark_home_not_signed_in')

    query.query_string = <<EOQ
{
  projects:transactables(take: 3, filters: [ACTIVE, FEATURED]) {
    name
    show_path
    cover_photo_thumbnail_url
    creator {
      profile_path
      avatar_url_thumb
    }
  }
  users(take: 6, filters: [FEATURED]) {
    profile_path
    avatar_url_bigger
    name_with_affiliation
    display_location
    short_bio: custom_attribute(name: "short_bio")
    role: custom_attribute(name: "role")
  }
  topics(filters: [FEATURED], arbitrary_order: ["Tutorials", "Upcoming Events", "In the News", "Sneak Peeks", "Let’s Chat", "Artist Corner"], take: 6) {
    name
    show_url
    listing_image_url
  }
}
EOQ
    query.save
  end

  def down
    # hallmark
    i = Instance.find_by(id: 5011)
    # this will work only on oregon
    return unless i
    i.set_context!
    query = i.graph_queries.find_by(name: 'hallmark_home_not_signed_in')

    query.query_string = <<EOQ
{
  projects:transactables(take: 3, filters: [ACTIVE, FEATURED]) {
    name
    show_path
    cover_photo_thumbnail_url
    creator {
      profile_path
      avatar_url_thumb
    }
  }
  users(take: 6, filters: [FEATURED]) {
    profile_path
    avatar_url_bigger
    name_with_affiliation
    display_location
    short_bio: custom_attribute(name: "short_bio")
    role: custom_attribute(name: "role")
  }
}

EOQ

    query.save
  end
end
