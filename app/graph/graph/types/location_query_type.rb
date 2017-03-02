module Graph
  module Types
    LocationQueryType = GraphQL::ObjectType.define do
      field :locations do
        type !types[Types::Location]
        resolve -> (_obj, _args, _ctx) { ::Location.first(10) }
      end

      field :location do
        type Types::Location
        argument :id, !types.ID
        resolve -> (_obj, args, _ctx) { LocationDrop.new(::Location.find(args[:id])) }
      end
    end
  end
end
