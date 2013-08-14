module NewrelicCarrierwaveTracker

  ::CarrierWave::MiniMagick.class_eval do
    include NewRelic::Agent::Instrumentation::ControllerInstrumentation

    add_method_tracer(:resize_to_limit)
    add_method_tracer(:resize_to_fill)
    add_method_tracer(:resize_and_pad)
    add_method_tracer(:resize_to_geometry_string)
    add_method_tracer(:convert)

  end

  ::CarrierWave::Storage::Fog.class_eval do
    def call_store_with_newrelic_trace(file)
      metrics = ["External/CarrierWave/Fog/store"]

      if NewRelic::Agent::Instrumentation::MetricFrame.recording_web_transaction?
        total_metric = 'External/allWeb'
      else
        total_metric = 'External/allOther'
      end

      metrics << total_metric
      self.class.trace_execution_scoped(metrics) do
        call_store_without_newrelic_trace(file)
      end
    end

    def call_retrieve_with_newrelic_trace(identifier)
      metrics = ["External/CarrierWave/Fog/retrieve"]

      if NewRelic::Agent::Instrumentation::MetricFrame.recording_web_transaction?
        total_metric = 'External/allWeb'
      else
        total_metric = 'External/allOther'
      end

      metrics << total_metric
      self.class.trace_execution_scoped(metrics) do
        call_retrieve_without_newrelic_trace(identifier)
      end
    end

    alias :call_store_without_newrelic_trace :store!
    alias :store! :call_store_with_newrelic_trace

    alias :call_retrieve_without_newrelic_trace :retrieve!
    alias :retrieve! :call_retrieve_with_newrelic_trace
  end
end
