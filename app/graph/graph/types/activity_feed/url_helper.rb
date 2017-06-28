module Graph
  module Types
    module ActivityFeed
      class UrlHelper
        include ActionDispatch::Routing::PolymorphicRoutes
        include Rails.application.routes.url_helpers

        def transactable_path(transactable)
          listing_path(transactable)
        end

        def activity_feed_event_path(activity_feed_event)
          polymorphic_path(activity_feed_event.followed)
        end
      end
    end
  end
end
