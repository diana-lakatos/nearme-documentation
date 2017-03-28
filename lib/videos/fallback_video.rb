# frozen_string_literal: true
module Videos
  class FallbackVideo
    def self.usable?(_url)
      true
    end

    def initialize(url)
      @url = url
    end

    def embed_code(_attributes)
      ''
    end
  end
end
