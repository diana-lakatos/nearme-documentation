module Graph
  module Mutations
    RootMutation = GraphQL::ObjectType.define do
      name 'RootMutation'

      # TODO: refactor
      field :customization_update, Graph::Types::Customizations::Customization do
        description 'Updates a customization'
        argument :id, !types.ID
        argument :form_configuration, !types.String
        argument :customization, !CustomizationInputType

        resolve ->(_object, args, ctx) {
          command = CustomizationUpdate.new(
            current_user: ctx[:current_user],
            id: args[:id],
            params: args[:customization].to_h,
            form_configuration_id: FormConfiguration.find_by!(name: args[:form_configuration]).id
          )
          command.call
          command.form.model
        }
      end

      field :customization_delete, Graph::Types::Customizations::Customization do
        description 'Removed a customization'
        argument :id, !types.ID
        argument :form_configuration, !types.String
        resolve ->(_object, args, ctx) {
          command = CustomizationDelete.new(
            current_user: ctx[:current_user],
            id: args[:id],
            params: {},
            form_configuration_id: FormConfiguration.find_by!(name: args[:form_configuration]).id
          )
          command.call
          command.form.model
        }
      end
    end

    CustomizationInputType = GraphQL::InputObjectType.define do
      name 'CustomizationInputType'
      description 'Properties for a Customization'

      argument :title, !types.String
    end
  end
end
