module Graph
  module Types
    module ActivityFeed
      class UrlHelper
        include ActionDispatch::Routing::PolymorphicRoutes
        include Rails.application.routes.url_helpers

        def transactable_path(transactable)
          listing_path(transactable)
        end
      end
    end
  end
end
