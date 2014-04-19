module Utils
  class InstanceViewsSeeder

    def go!(path="**/*")
      Dir["app/views/#{path}"].each do |file_path|
        # we don't want to include mailer templates, we handle them separately
        next if file_path.include?('_mailer/') && file_path.include?('.liquid')
        next if Pathname.new(file_path).directory?
        File.open(file_path, 'r') do |file|
          file_path.sub!("app/views/", '')
          create_instance_view_for_path(file_path, file.read)
        end
      end
    end

    def create_instance_view_for_path(file_path, content)
      attributes = {}
      path_components = file_path.split('/')
      file_name = path_components.last
      if file_name[0] == '_'
        attributes[:partial] = true
      else
        attributes[:partial] = false
      end
      name_components = file_name.split('.')
      pure_name = name_components.shift
      name_components.each do |ext|
        if Mime::SET.symbols.map(&:to_s).include?(ext)
          attributes[:format] = ext
        elsif ActionView::Template::Handlers.extensions.map(&:to_s).include?(ext)
          attributes[:handler] = ext
        elsif I18n.available_locales.map(&:to_s).include?(ext)
          attributes[:locale] = ext
        end
      end
      attributes[:format] ||= 'en'
      path_components[path_components.length-1] = pure_name
      attributes[:path] = path_components.join('/')
      attributes[:body] = content
      InstanceView.create(attributes) unless InstanceView.where(attributes).present?
    rescue => e
      puts "Could not create instance view for #{file_path}: #{e.message}"
    end

  end
end
