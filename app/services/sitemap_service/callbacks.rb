module SitemapService::Callbacks
  extend ActiveSupport::Concern

  included do
    %w(create update destroy).each do |action|
      conditions_method = "should_#{action}_sitemap_node?".to_sym
      method_name = "#{action}_sitemap_node".to_sym

      after_commit method_name, on: action.to_sym

      # If the method is not defined, we execute the callbacks everytime. Otherwise, it will
      # check for #should_create_sitemap_node, #should_update_sitemap_node & #should_destroy_sitemap_node
      #
      should_execute_callback = if defined?(self.send(conditions_method)).present?
        self.send(conditions_method) rescue false
      else
        true
      end

      define_method(method_name) do
        SitemapNodeUpdateJob.perform(action.to_sym, self) if should_execute_callback
      end
    end
  end
end
