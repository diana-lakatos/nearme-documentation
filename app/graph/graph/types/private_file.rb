# frozen_string_literal: true
module Graph
  module Types
    PrivateFile = GraphQL::ObjectType.define do
      name 'PrivateFile'
      description 'A attachment file, to retrieve url please call /api/user/custom_attachments/:id'

      field :id, types.ID
      field :created_at, types.String
      field :size_bytes, types.Int do
        resolve ->(obj, _, _) { obj.file.file.size }
      end
      field :file_name, types.String do
        resolve ->(obj, _, _) { obj[:file] }
      end
      field :content_type, types.String do
        resolve ->(obj, _, _) { obj.file.file.content_type }
      end
    end
  end
end
