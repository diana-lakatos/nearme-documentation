module Delayed
  module Plugins
    class Raygun < Plugin
      module Notify
        def error(job, error)
          ::Raygun.track_exception(error,
            custom_data: {
              delayed: {
                error_class:   error.class.name,
                error_message: "#{error.class.name}: #{error.message}",
                parameters:    {
                  failed_job: job.inspect,
                }
              }
          })
          super if defined?(super)
        end
      end

      callbacks do |lifecycle|
        lifecycle.before(:invoke_job) do |job|
          payload = job.payload_object
          payload = payload.object if payload.is_a? Delayed::PerformableMethod
          payload.extend Notify
        end
      end
    end
  end
end

Delayed::Worker.plugins << Delayed::Plugins::Raygun
