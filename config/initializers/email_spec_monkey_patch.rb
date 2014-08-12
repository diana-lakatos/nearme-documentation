if defined?(EmailSpec)
  module EmailSpec
    class TestObserver
      def self.delivered_email(message)
      end
    end
  end
end
