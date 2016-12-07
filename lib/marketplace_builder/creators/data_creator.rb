# frozen_string_literal: true
require 'yaml'

module MarketplaceBuilder
  module Creators
    class DataCreator < Creator
      protected

      def source
        raise NotImplementedError
      end

      def get_data
        path = File.join(@theme_path, source)

        data = load_dir(path) if File.directory? path

        data = load_file(path) if File.file? path

        data = [] if data.nil? || !data
        data
      end

      private

      def load_dir(dir)
        files = Dir.entries(dir).select { |path| File.file?(path) && /\.keep$/.match(path).nil? }
        out = {}
        files.each do |filename|
          out[File.basname(filename, '.yml')] = load_file(File.join(dir, filename))
        end
        out
      end

      def load_file(path)
        YAML.load_file(path)
      end
    end
  end
end
