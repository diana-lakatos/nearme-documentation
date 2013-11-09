module Liquid
  # This will parse the template with a LocalFileSystem implementation rooted at 'template_path'.
  class BlankFileSystem
    # Called by Liquid to retrieve a template file
    def read_template_file(template_path, context)
      format = template_path.split('.').last.to_sym
      details = {platform_context: [context.registers[:controller].platform_context], handlers: [:liquid], formats: [format]}
      template = EmailResolver.instance.find_templates(template_path, '', true, details).first

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
