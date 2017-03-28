# frozen_string_literal: true
module Graph
  module Resolvers
    class MessageThread
      def call(user, arguments, _ctx)
        @user = user.source
        @thread_id = arguments[:id]
        resolve_by
      end

      def resolve_by
        message = @user.user_messages.find(@thread_id).decorate
        messages = Messages::ForThreadQuery.new.call(message).by_created.decorate

        Thread.new(messages, @user)
      end
    end
  end
end
