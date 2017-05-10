# frozen_string_literal: true
module Graph
  module Resolvers
    class MessageThreads
      def call(user, arguments, _ctx)
        @user_model = Resolvers::User.find_model(user)
        @take = arguments[:take]
        resolve_by
      end

      def resolve_by
        messages_grouped = UserMessagesDecorator.new(initial_scope, @user_model).inbox.fetch.map(&:last)
        messages_grouped.map { |messages| ThreadDecorator.new(messages, @user_model) }
      end

      private

      def initial_scope
        @user_model.user_messages
      end
    end
  end
end
