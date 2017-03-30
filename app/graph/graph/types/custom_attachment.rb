# frozen_string_literal: true
module Graph
  module Types
    CustomAttachment = GraphQL::ObjectType.define do
      name 'CustomAttachment'

      field :id, types.ID
      field :url, !types.String
      field :content_type, !types.String
    end
  end
end
