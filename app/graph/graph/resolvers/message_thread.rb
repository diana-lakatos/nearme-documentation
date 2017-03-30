# frozen_string_literal: true
module Graph
  module Resolvers
    class MessageThread
      def call(user, arguments, _ctx)
        @user_model = ::User.find(user.id)
        @thread_id = arguments[:id]
        resolve_by
      end

      def resolve_by
        message = @user_model.user_messages.find(@thread_id).decorate
        messages = Messages::ForThreadQuery.new.call(message).by_created.decorate

        Thread.new(messages, @user_model)
      end
    end
  end
end
