# The purpose of this class is to add .enqueue method to all Mailers
# so we can use syntax Mailer.enqueue.send_method instead of MailerJob.perform(Mailer, send_method)
module Job::SyntaxEnhancer
  extend ActiveSupport::Concern

    def enqueue(*args)
      Proxy.new(self, job_class)
    end

    def enqueue_later(when_perform, *args)
      DelayedProxy.new(self, job_class, when_perform)
    end

    private

    def job_class
      if self.class.to_s === 'Class'
        (name.match(/Mailer$/) ? "MailerJob" : "#{name}Job").constantize
      else
        "#{self.class.name}Job".constantize
      end
    end

  class Proxy
    def initialize(klass, job_class)
      @klass = klass
      @job_class = job_class
    end

    def method_missing(method, *args)
      @job_class.perform(@klass, method, *args)
    end
  end

  class DelayedProxy
    def initialize(klass, job_class, when_perform)
      @klass = klass
      @job_class = job_class
      @when_perform = when_perform
    end

    def method_missing(method, *args)
      @job_class.perform_later(@when_perform, @klass, method, *args)
    end
  end
end
