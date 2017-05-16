# frozen_string_literal: true
module Graph
  module Types
    EsImage = GraphQL::ObjectType.define do
      name 'EsImage'

      field :id, types.ID do
        resolve ->(obj, _arg, _ctx) { obj.id }
      end
      field :url, types.String, 'image url, ex: thumb: url(version: "thumb")' do
        argument :version, types.String, default_value: 'thumb'
        resolve lambda { |obj, arg, _ctx|
          versions = obj.versions || obj
          versions[arg[:version]].url
        }
      end
    end
  end
end
