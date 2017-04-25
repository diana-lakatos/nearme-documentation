# frozen_string_literal: true
module Graph
  module Types
    PrivateFile = GraphQL::ObjectType.define do
      name 'PrivateFile'
      description 'A attachment file, to retrieve url please call /custom_attachments/:id'

      field :id, types.ID
      field :name, !types.String do
        resolve ->(obj, _, _) { obj.file_name }
      end
      field :file_name, types.String
      field :content_type, types.String
    end
  end
end
