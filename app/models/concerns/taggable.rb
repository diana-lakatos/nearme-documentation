module Taggable
  extend ActiveSupport::Concern

  included do
    acts_as_taggable_on :tags

    def tags_as_comma_string(tagger = nil)
      (tag_list + tags.pluck(:name)).uniq.join(',')
    end
  end
end
