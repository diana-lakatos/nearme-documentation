# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class TopicsCreator < DataCreator
      def execute!
        logger.info 'Updating topics'

        data = get_data

        data.each do |hash|
          hash = hash.symbolize_keys
          logger.debug "Creating topic: #{hash[:name]}"

          hash[:category] = Category.find_by(name: hash[:category]) if hash[:category].present?
          remote_cover_image_url = hash.delete(:remote_cover_image_url) || nil

          hash.each do |key, _value|
            raise MarketplaceBuilder::Error, "#{key} is not allowed in Topic settings" unless whitelisted_properties.include?(key)
          end

          topic = Topic.where(hash).first_or_create!

          next unless remote_cover_image_url
          topic.remote_cover_image_url = remote_cover_image_url
          logger.debug "Loading topic cover image from: #{remote_cover_image_url}"
          topic.save!
        end
      end

      def cleanup!
        topics = get_data

        unused_topics = if topics.empty?
                          Topic.all
                        else
                          Topic.where('name NOT IN (?)', topics.map { |topic| topic['name'] })
                        end

        unused_topics.each { |topic| logger.debug "Removing unused topic: #{topic.name}" }
        unused_topics.destroy_all
      end

      private

      def whitelisted_properties
        [:name, :category, :description, :featured, :remote_cover_image_url]
      end

      private

      def source
        File.join('topics', 'topics.yml')
      end
    end
  end
end
