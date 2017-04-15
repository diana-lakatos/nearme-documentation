# frozen_string_literal: true
module Graph
  module Types
    File = GraphQL::ObjectType.define do
      name 'File'
      description 'A attachment file'

      field :url, !types.String
      field :name, !types.String do
        resolve ->(obj, _, _) { obj.file_name }
      end
      field :file_name, types.String
      field :content_type, types.String
    end
  end
end
