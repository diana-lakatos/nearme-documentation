# frozen_string_literal: true
class HallmarkHomepageViewRevert < ActiveRecord::Migration
  def up
    Instance.transaction do
      Instances::InstanceFinder.get(:hallmark).each do |i|
        i.set_context!

        query_string = <<EOC
          query HallmarkHomeNotSignedInQuery($follower_id: ID){
            projects:transactables(paginate: {page: 1, per_page: 3}, filters: [ACTIVE, FEATURED]) {
              items{
                id
                is_followed(follower_id: $follower_id)
                name
                show_path
                cover_photo_thumbnail_url
                creator {
                  id
                  profile_path
                  avatar_url_thumb
                }
              }
            }
            users(take: 6, filters: [FEATURED]) {
              id
              is_followed(follower_id: $follower_id)
              profile_path
              avatar_url_bigger
              name_with_affiliation
              display_location
              short_bio: custom_attribute(name: "short_bio")
              role: custom_attribute(name: "role")
            }
            topics(filters: [FEATURED], arbitrary_order: ["Tutorials", "Upcoming Events", "In the News", "Sneak Peeks", "Let’s Chat", "Artist Corner"], take: 6) {
              id
              is_followed(follower_id: $follower_id)
              name
              show_url
              listing_image_url
            }
          }
EOC

        i.graph_queries.where(name: 'hallmark_home_not_signed_in').first.update(query_string: query_string)
      end
    end
  end

  def down
    Instance.transaction do
      Instances::InstanceFinder.get(:hallmark).each do |i|
        i.set_context!

        query_string = <<EOC
          query HallmarkHomeNotSignedInQuery($follower_id: ID){
            projects:transactables(take: 3, filters: [ACTIVE, FEATURED]) {
              id
              is_followed(follower_id: $follower_id)
              name
              show_path
              cover_photo_thumbnail_url
              creator {
                id
                profile_path
                avatar_url_thumb
              }
            }
            users(take: 6, filters: [FEATURED]) {
              id
              is_followed(follower_id: $follower_id)
              profile_path
              avatar_url_bigger
              name_with_affiliation
              display_location
              short_bio: custom_attribute(name: "short_bio")
              role: custom_attribute(name: "role")
            }
            topics(filters: [FEATURED], arbitrary_order: ["Tutorials", "Upcoming Events", "In the News", "Sneak Peeks", "Let’s Chat", "Artist Corner"], take: 6) {
              id
              is_followed(follower_id: $follower_id)
              name
              show_url
              listing_image_url
            }
          }
EOC

        i.graph_queries.where(name: 'hallmark_home_not_signed_in').first.update(query_string: query_string)
      end
    end
  end
end
