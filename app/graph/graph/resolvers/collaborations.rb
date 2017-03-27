# frozen_string_literal: true
module Graph
  module Resolvers
    class Collaborations
      def call(user, args, _ctx)
        resolve_by(user.source.transactable_collaborators, args)
      end

      def resolve_by(relation, arguments)
        arguments.keys.reduce(relation) do |relation, argument_key|
          public_send("resolve_by_#{argument_key}", relation, arguments[argument_key])
        end
      end

      def resolve_by_filters(relation, filters)
        filters.reduce(relation) do |scoped_relation, filter|
          scoped_relation.public_send(FILTER_SCOPE_MAP.fetch(filter))
        end
      end

      FilterEnum = GraphQL::EnumType.define do
        name 'CollaborationFilters'
        value('PENDING_RECEIVED_INVITATION', 'Pending received invitations')
        value('APPROVED', 'Approved by both owner and user')
      end

      FILTER_SCOPE_MAP = {
        'PENDING_RECEIVED_INVITATION' => :pending_received_invitation,
        'APPROVED' => :approved
      }.freeze
    end
  end
end
