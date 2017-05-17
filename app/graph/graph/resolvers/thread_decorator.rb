# frozen_string_literal: true
module Graph
  module Resolvers
    class ThreadDecorator
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
