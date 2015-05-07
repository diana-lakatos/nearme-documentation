module Job::HighPriority
  extend ActiveSupport::Concern

  module ClassMethods
    def queue
      'high_priority'
    end
  end
end
