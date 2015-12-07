module Liquid
  # This will parse the template with a LocalFileSystem implementation rooted at 'template_path'.
  class BlankFileSystem
    # Called by Liquid to retrieve a template file
    def read_template_file(template_path, context)
      format = template_path.split('.').last.to_sym
      details = {}

      begin
        details = {
          handlers: [:liquid],
          formats: [format],
          locale: [::I18n.locale]
        }.merge(context.registers[:controller].send(:details_for_lookup))

        template_body = InstanceViewResolver.instance.get_body(template_path.split('.').first, '', true, details)
      rescue
        Rails.logger.error "Liquid::BlankFileSystem #{$!}. Details: #{details}"
      end

      # Fallback to English
      if template_body.nil? && details[:locale].first != :en
        details[:locale] = [:en]
        template_body = InstanceViewResolver.instance.get_body(template_path.split('.').first, '', true, details)
      end

      if template_body.nil?
        template_path_splited = template_path.split('/')
        template_path_splited[-1] = "_#{template_path_splited[-1]}"
        context.registers[:controller].view_paths.each do |view_path|
          if path = view_path.try(:to_path)
            if File.exists?(File.join(path, "#{template_path_splited.join('/')}.liquid"))
              return File.read(File.join(path, "#{template_path_splited.join('/')}.liquid"))
            end
          end
        end
      else
        template_body
      end
    end
  end
end
