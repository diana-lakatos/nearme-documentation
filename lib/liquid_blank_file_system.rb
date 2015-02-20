module Liquid
  # This will parse the template with a LocalFileSystem implementation rooted at 'template_path'.
  class BlankFileSystem
    # Called by Liquid to retrieve a template file
    def read_template_file(template_path, context)
      format = template_path.split('.').last.to_sym
      details = {}
      begin
        details = {instance_type_id: context.registers[:controller].platform_context.instance_type.try(:id), instance_id: context.registers[:controller].platform_context.instance.id, handlers: [:liquid], formats: [format], locale: [::I18n.locale]}
        template = InstanceViewResolver.instance.find_templates(template_path, '', true, details).first
      rescue
        Rails.logger.error "Liquid::BlankFileSystem #{$!}. Details: #{details}"
      end

      if template.nil?
        template_path_splited = template_path.split('/')
        template_path_splited[-1] = "_#{template_path_splited[-1]}"
        File.read(File.join('app/views', "#{template_path_splited.join('/')}.liquid"))
      else
        template.render
      end
    end
  end
end
