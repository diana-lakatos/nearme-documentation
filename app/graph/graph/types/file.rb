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
    end
  end
end
