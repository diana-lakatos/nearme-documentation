# The purpose of this class is to add .enqueue method to all Mailers
# so we can use syntax Mailer.enqueue.send_method instead of MailerJob.perform(Mailer, send_method)
module Job::SyntaxEnhancer

  def self.included(base)
    base.send(:attr_accessor, :job_class)
    base.send(:attr_accessor, :enqueued_methods)
  end

  def self.extended(base)
    base.class_attribute :job_class
    # the <base.name>Job class might not be defined, that's why string
    base.send(:job_class=, "#{base.name}Job")
  end

  def enqueue(*args)
    Proxy.new(self, get_job_class)
  end

  def enqueue_later(when_perform, *args)
    DelayedProxy.new(self, get_job_class, when_perform)
  end

  private

  def get_job_class
    # .to_s on job_class makes it possible to pass both string and class
    (job_class ? job_class.to_s : "#{self.class.name}Job").constantize
  end

  class Proxy
    def initialize(klass, job_class)
      @klass = klass
      @job_class = job_class
    end

    def method_missing(method, *args)
      if @klass.respond_to?(:enqueued_methods)
        @klass.enqueued_methods ||= []
        @klass.enqueued_methods << method.to_s
      end
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
