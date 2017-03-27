# frozen_string_literal: true
class AddActivityFeedGraphQueryToHallmark < ActiveRecord::Migration
  HALLMARK_ID = 5011
  def up
    Instance.where(id: [HALLMARK_ID]).each do |i|
    i.set_context!
    i.graph_queries.create!(
      name: 'activity_feed',
      query_string: <<EOQ
{
  feed{
    owner_id
    owner_type
    has_next_page
    events_next_page
    events{
      id
      creator_id
      event
      created_at
      name
      header_image
      has_body
      description
      is_status_update_event
      is_comment_event
      is_photo_event
      is_reportable
      event_source_type
      url
      event_source{
        ... on ActivityFeedComment {
          id
          body
          created_at
          updated_at
          followed_path
          url
          activity_feed_images{
            id
            url: url(version: "space_listing")
            image_original_width
            image_original_height
          }
        }
        ... on ActivityFeedUserStatusUpdate {
          id
          text
          url
          activity_feed_images{
            id
            url: url(version: "space_listing")
            image_original_width
            image_original_height
          }
        }
        ... on ActivityFeedPhoto {
          id
          created_at
          updated_at
          url
          image {
            url: url(version: "space_listing")
          }
        }
        ... on ActivityFeedGeneric { id created_at updated_at }
      }
      details{
        text
        image
      }
      followed {
        id
        path
        class
      }
      comments{
        id
        body
        created_at
        commented_own_thread
        url
        activity_feed_images{
          url: url(version: "space_listing")
          image_original_width
          image_original_height
        }
        creator{
          id
          name
          profile_path
          avatar_url_thumb
        }
        commentable{
          id
          url
          creator_id
        }
      }
    }
  }
}
EOQ
    )
    end
  end

  def down
    Instance.where(id: [HALLMARK_ID]).each do |i|
    i.set_context!
    i.graph_queries.find_by(name: 'activity_feed').destroy
    end
  end
end
