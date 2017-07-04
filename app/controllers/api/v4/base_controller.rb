# frozen_string_literal: true
module Api
  module V4
    class BaseController < Api::BaseController
      protected

      def respond(object, options = {})
        options[:location] ||= return_to(object)
        api_respond_with(api_namespace(object), options)
      end

      def api_namespace(*args)
        [:api, :v4] + args
      end

      def api_respond_with(namespaced_object, options = {})
        if params[:page_id].present? && form_configuration.present? && namespaced_object.last.errors.present?
          result = respond_with(*namespaced_object, options) do |format|
            submitted_form ||= {}
            submitted_form = { form_configuration.name => { form: namespaced_object.last.tap(&:prepopulate!),
                                                            configuration: form_configuration } }
            format.html do
              RenderCustomPage.new(
                controller: self,
                page: Page.find(params[:page_id]),
                params: params,
                submitted_form: submitted_form
              ).render
            end

            format.json do
              render json: submitted_form.first[1][:form].errors.messages, status: 422 # blargh
            end
          end
        else
          result = respond_with(*namespaced_object, options)
        end

        render_redirect_url_as_json if html_redirect?(result) && render_html_after_ajax_call?
      end

      def render_redirect_url_as_json
        redirect_json = { redirect: response.location }
        # Clear out existing response
        self.response_body = nil
        render(
          json: redirect_json,
          content_type: 'application/json',
          status: 200
        )
      end

      def render_html_after_ajax_call?
        request.xhr? && request.format.html?
      end

      def html_redirect?(result)
        result == %(<html><body>You are being <a href="#{response.location}">redirected</a>.</body></html>)
      end

      def secure_links?
        require_ssl?
      end
      helper_method :secure_links?

      def require_ssl?
        !request.ssl? && PlatformContext.current.require_ssl?
      end

      def platform_context
        @platform_context = PlatformContext.current.decorate
      end
      helper_method :platform_context

      def current_instance
        PlatformContext.current.instance
      end
      helper_method :current_instance

      def form_configuration
        @form_configuration ||= FormConfiguration.find_by(id: params[:form_configuration_id]).tap do |fc|
          Authorize.new(object: fc, user: current_user, params: params).call
        end
      end

      def return_to(form)
        return_to_for_form(form) || return_to_for_params || root_path
      end

      def return_to_for_form(form)
        return if form_configuration.blank? || form_configuration.return_to.blank?

        LiquidTemplateParser.new
                            .parse(form_configuration.return_to, current_user: current_user, form: form)
                            .presence
      end

      def return_to_for_params
        params[:redirect_to].presence || params[:return_to]
      end
    end
  end
end
