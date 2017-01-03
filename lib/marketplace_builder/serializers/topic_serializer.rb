module MarketplaceBuilder
  module Serializers
    class TopicSerializer < BaseSerializer
      resource_name -> (t) { "topics/topics" }

      property :topics

      def topics(instance)
        Topic.where(instance_id: @model.id).all.map do |topic|
          { 'name' => topic.name,
            'description' => topic.description,
            'featured' => topic.featured, 
            'remote_cover_image_url' => topic.remote_cover_image_url
          }
        end
      end
    end
  end
end
