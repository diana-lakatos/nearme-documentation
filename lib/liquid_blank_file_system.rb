# frozen_string_literal: true
module Liquid
  # This will parse the template with a LocalFileSystem implementation rooted at 'template_path'.
  class BlankFileSystem
    # Called by Liquid to retrieve a template file
    def read_template_file(template_path, context)
      splitted_path = template_path.split('.')
      path = splitted_path.first
      format = splitted_path.last
      details = {
        handlers: [:liquid],
        formats: [format],
        locale: [::I18n.locale]
      }.merge(context.registers[:controller].send(:details_for_lookup))
      result = begin
        context.registers[:controller].lookup_context.find_template(path, '', true, details).source
      rescue
        # our UI is not great, MPO might not check 'partial' - this is why this rescue
        begin
          context.registers[:controller].lookup_context.find_template(path, '', false, details).source
        rescue
          Rails.logger.warn("Liquid Error: can't find LiquidView with path #{path}. Make sure it has been added in Marketplace Admin")
          ''
        end
      end
      result = LiquidView::WrappedLiquidPartialBody.new(partial: path).wrapped_body(result) if LiquidView::CommentWrapperGuard.authorized?(context.registers[:action_view])
      result
    end
  end
end
