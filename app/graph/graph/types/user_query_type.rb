module Graph
  module Types
    UserQueryType = GraphQL::ObjectType.define do
      field :users do
        type !types[Types::User]
        argument :filters, types[Types::UserFilterEnum]
        argument :take, types.Int

        resolve Resolvers::Users.new
      end

      field :user do
        type Types::User
        argument :id, types.ID
        resolve -> (_obj, args, _ctx) { UserDrop.new(::User.find(args[:id])) }
      end
    end
  end
end
