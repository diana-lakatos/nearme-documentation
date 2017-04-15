# frozen_string_literal: true
module Elastic
  class CustomizationDrop < BaseDrop
    delegate :properties, :id, :name, to: :source

    def custom_images
      source.custom_images.each_with_object({}) do |img, group|
        group[img.name] = img
      end
    end
    def custom_attachments
      source.custom_attachments.each_with_object({}) do |attachment, group|
        group[attachment.name] =attachment
      end
    end
  end
end
