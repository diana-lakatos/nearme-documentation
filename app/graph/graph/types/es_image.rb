# frozen_string_literal: true
module Graph
  module Types
    EsImage = GraphQL::ObjectType.define do
      name 'EsImage'

      field :id, types.ID do
        resolve ->(obj, _arg, _ctx) { obj.id }
      end
      field :url,
            !types.String,
            'image url, ex: thumb: url(version: "thumb")' do
        argument :version, !types.String
        resolve ->(obj, arg, _ctx) { obj.versions[arg[:version]].url }
      end
    end
  end
end
