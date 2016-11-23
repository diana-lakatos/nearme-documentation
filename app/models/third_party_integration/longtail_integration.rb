# frozen_string_literal: true
class ThirdPartyIntegration
  class LongtailIntegration < ThirdPartyIntegration
    store :settings, accessors: %i(token page_slug), coder: Hash

    validates :token, :page_slug, presence: true

    def host
      production? ? 'http://api.longtailux.com' : 'http://api-staging.longtailux.com'
    end

    protected

    def production?
      environment == 'production'
    end
  end
end
