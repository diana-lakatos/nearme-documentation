# frozen_string_literal: true
class LiquidView
  class CommentWrapperGuard
    class << self
      def authorized?(context)
        new(context).authorized?
      end
    end

    def initialize(context)
      @context = context
    end

    def authorized?
      instance_admin_in_debugging_mode? &&
        html_request_and_response? &&
        response_success?
    end

    protected

    def instance_admin_in_debugging_mode?
      development_mode? || (debugging_enabled? && user_is_instance_admin?)
    end

    def development_mode?
      Rails.env.development? || Rails.env.staging?
    end

    def debugging_enabled?
      PlatformContext.current&.instance&.debugging_mode_for_admins?
    end

    def user_is_instance_admin?
      @context.instance_variable_get(:'@current_user')&.instance_admin?
    end

    def html_request_and_response?
      (@context.request&.format&.to_s&. =~ %r{text\/html}).present? &&
        @context.response&.headers&.fetch('Content-Type', '').include?('text/html')
    end

    def response_success?
      @context.response&.status == 200
    end
  end
end
