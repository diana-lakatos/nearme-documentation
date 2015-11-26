module Taggable
  extend ActiveSupport::Concern

  included do
    acts_as_taggable_on :tags

    before_save :set_tag_ownership

    def set_tag_ownership
      if tag_list_changed?
        self.set_owner_tag_list_on(self.user, :tags, self.tag_list)
        self.tag_list = nil
      end
    end

    def self.tags(tagger=nil)
      conditions = {
        taggings: {
          taggable_type: self.name
        }
      }

      conditions.merge!({
        taggings: {
          tagger_id: tagger.id,
          tagger_type: tagger.class.name
        }
      }) if tagger.present?

      Tag.includes(:taggings).where(conditions).order(:name)
    end

    def tags_as_comma_string(tagger=nil)
      tags.pluck(:name).join(',')
    end
  end
end
