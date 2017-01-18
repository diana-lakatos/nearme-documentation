# frozen_string_literal: true
class UpdateGraphqlForHallmarkHomePages < ActiveRecord::Migration
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
    cover_photo_url
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
  }
  topics(filters: [FEATURED], arbitrary_order: ["Featured Artist", "Featured Series", "Ask a Keepsake Artist", "2017 Convention", "Upcoming Events", "Tutorials"], take: 6) {
    name
    show_url
    background_style
    background_style_big
  }
}
EOQ

    query.save
  end
end
