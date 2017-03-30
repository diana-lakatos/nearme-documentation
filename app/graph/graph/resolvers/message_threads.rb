# frozen_string_literal: true
module Graph
  module Resolvers
    class MessageThreads
      def call(user, arguments, _ctx)
        @user_model = ::User.find(user.id)
        @take = arguments[:take]
        resolve_by
      end

      def resolve_by
        messages_grouped = UserMessagesDecorator.new(initial_scope, @user_model).inbox.fetch.map(&:last)
        messages_grouped.map { |messages| Thread.new(messages, @user_model) }
      end

      private

      def initial_scope
        @user_model.user_messages
      end
    end

    class Thread
      attr_reader :messages

      def initialize(messages, user)
        @messages = messages
        @user = user
      end

      def last_message
        @last_message ||= @messages.last
      end

      def participant
        last_message.the_other_user(@user)
      end

      def url
        last_message.show_path
      end

      def read?
        @messages.all? { |m| m.source.read_for?(@user) }
      end

      alias is_read read?
    end
  end
end
