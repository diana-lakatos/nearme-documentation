module Job::LongRunning
  extend ActiveSupport::Concern

  module ClassMethods
    def queue
      'long_running'
    end
  end
end
