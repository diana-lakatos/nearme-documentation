# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class TopicsCreator < DataCreator
      def execute!
        MarketplaceBuilder::Logger.info 'Topics'

        data = get_data
        cleanup!(data) if @mode == MarketplaceBuilder::MODE_REPLACE

        data.each do |hash|
          hash = hash.symbolize_keys
          MarketplaceBuilder::Logger.log "\t - #{hash[:name]}"

          hash[:category] = Category.find_by(name: hash[:category]) if hash[:category].present?
          remote_cover_image_url = hash.delete(:remote_cover_image_url) || nil

          hash.each do |key, _value|
            raise MarketplaceBuilder::Error, "#{key} is not allowed in Topic settings" unless whitelisted_properties.include?(key)
          end

          topic = Topic.where(hash).first_or_create!

          if remote_cover_image_url
            topic.remote_cover_image_url = remote_cover_image_url
            topic.save!
          end
        end
      end

      private

      def whitelisted_properties
        [:name, :category, :description, :featured, :remote_cover_image_url]
      end

      private

      def cleanup!(data)
        used_topics = data.map do |props|
          props['name']
        end

        Topic.where('name NOT IN (?)', used_topics).destroy_all
      end

      def source
        File.join('topics', 'topics.yml')
      end
    end
  end
end
