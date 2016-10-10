module SitemapService::Callbacks
  extend ActiveSupport::Concern

  included do
    %w(create update destroy).each do |action|
      conditions_method = "should_#{action}_sitemap_node?".to_sym
      method_name = "#{action}_sitemap_node".to_sym

      after_commit method_name, on: action.to_sym

      define_method(method_name) do
        should_execute_callback = if defined?(send(conditions_method))
                                    send(conditions_method) rescue false
                                  else
                                    true
        end

        SitemapNodeUpdateJob.perform(action.to_sym, self) if should_execute_callback && (Rails.env.production? || Rails.env.staging?)
      end
    end
  end
end
