# frozen_string_literal: true
module ElasticIndexer
  class CategorySerializer < BaseSerializer
    attributes :name_of_root,
               :position,
               :name,
               :permalink,
               :slug,
               :is_root

    def name_of_root
      return if object.root?

      Category.with_deleted.find_by(permalink: object.permalink.split('/').first).name
    end

    def is_root
      object.root?
    end

    def slug
      name.parameterize
    end
  end
end
