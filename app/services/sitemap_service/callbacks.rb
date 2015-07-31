module SitemapService::Callbacks
  extend ActiveSupport::Concern

  included do
    %w(create update destroy).each do |action|
      callback_method = "after_#{action}".to_sym
      conditions_method = "should_#{action}_sitemap_node?"
      method_name = "#{action}_sitemap_node".to_sym
      
      self.send(callback_method, method_name)

      # If the method is not defined, we execute the callbacks everytime. Otherwise, it will
      # check for #should_create_sitemap_node, #should_update_sitemap_node & #should_destroy_sitemap_node
      #
      should_execute_callback = if defined?(self.send(conditions_method.to_sym)).present?
        self.send(conditions_method.to_sym)
      else
        true
      end

      define_method(method_name) do
        SitemapNodeUpdateJob.perform_async(action.to_sym, self) if should_execute_callback
      end
    end
  end  
end
