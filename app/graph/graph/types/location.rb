module Graph
  module Types
    Location = GraphQL::ObjectType.define do
      name 'Location'
      description 'A place'

      global_id_field :id

      field :id, !types.Int
      field :name, !types.String
      field :description, !types.String
      field :availability, !types.String
      field :name_and_desc, !types.String do
        resolve -> (obj, args, ctx) {
          obj.name + obj.description
        }
      end
      field :company, Types::Company
    end
  end
end
