module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups
    module Addons
      # Name of the component method
      def prefix(wrapper_options = nil)
        @prefix ||= begin
          options[:prefix].to_s.html_safe if options[:prefix].present?
        end
      end

      def has_prefix?
        prefix.present?
      end

      def suffix(wrapper_options = nil)
        @suffix ||= begin
          options[:suffix].to_s.html_safe if options[:suffix].present?
        end
      end

      def has_suffix?
        suffix.present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::Addons)
