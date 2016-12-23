# frozen_string_literal: true
module Graph
  module Types
    Image = GraphQL::ObjectType.define do
      name 'Image'
      description 'Generic image'

      field :url,
            !types.String,
            'image url, ex: thumb: url(version: "thumb")' do
        argument :version, !types.String
        resolve -> (obj, arg, _ctx) { obj.url(arg[:version]) }
      end
    end
  end
end
