# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class TemplatesCreator < Creator
      def execute!
        templates = get_templates
        return if templates.empty?

        logger.info "Updating #{object_name.pluralize.underscore.humanize.downcase}"

        templates.each do |template|
          create!(template)
          success_message(template)
        end
      end

      protected

      def success_message(template)
        logger.debug "Creating #{object_name.underscore.humanize.downcase}: #{template.liquid_path}"
      end

      def object_name
        raise NotImplementedError
      end

      def default_template_options
        {}
      end

      def create!
        raise NotImplementedError
      end

      def get_templates
        @templates ||= get_templates_from_dir(File.join(@theme_path, folder_name))
        @templates
      end

      private

      def folder_name
        object_name.pluralize.underscore
      end

      def get_templates_from_dir(template_folder)
        template_files = Dir.glob("#{template_folder}/**/*").select { |path| File.file?(path) && /\.keep$/.match(path).nil? }
        template_files.map! do |filename|
          options = default_template_options
          options[:partial] = !/^_/.match(File.basename(filename)).nil?
          load_file_with_yaml_front_matter(filename, template_folder, options)
        end
      end

      def load_file_with_yaml_front_matter(path, template_folder, config = {})
        body = File.read(path)
        regex = /\A---(.|\n)*?---\n/

        # search for YAML front matter
        yfm = body.match(regex)
        if yfm
          config = config.merge(YAML.load(yfm[0]))
          body.gsub!(regex, '')
        end
        config = config.merge(body: body)

        config['liquid_path'] ||= path.sub("#{template_folder}/", '').gsub(/\.[a-z]+$/, '').gsub(/\/_(?=[^\/]+$)/, '/') # first remove folder path, then file extension, then `_` partial symbol
        config['name'] ||= File.basename(path, '.*').sub(/^_/, '').humanize.titleize
        config['path'] ||= path

        OpenStruct.new(config)
      end
    end
  end
end
