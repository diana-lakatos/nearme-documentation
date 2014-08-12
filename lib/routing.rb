# http://hawkins.io/2012/03/generating_urls_whenever_and_wherever_you_want/
module Routing
  extend ActiveSupport::Concern

  included do
    def default_url_options
      Rails.application.routes.default_url_options
    end
  end
end
