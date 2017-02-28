module Graph
  module Types
    module ActivityFeed
      class UrlHelper
        include ActionDispatch::Routing::PolymorphicRoutes
        include Rails.application.routes.url_helpers
      end
    end
  end
end
