module SendleApi
  class Package < OpenStruct
    def attributes
      as_json['table']
    end
  end

  module Packages
    class << self
      def all
        from_file.map do |attributes|
          create attributes
        end
      end

      def create(attributes)
        Package.new(attributes)
      end

      private

      def from_file
        YAML.load_file(
          File.join(__dir__, 'packages.yml')
        )
      end
    end
  end
end
