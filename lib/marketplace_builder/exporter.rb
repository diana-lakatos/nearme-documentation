module MarketplaceBuilder
  class Exporter
    AVAILABLE_SERIALIZERS_LIST = {
      Serializers::InstanceSerializer            => 'yml',
      Serializers::TranslationsSerializer        => 'yml',
      Serializers::TransactableTypeSerializer    => 'yml',
      Serializers::InstanceProfileTypeSerializer => 'yml',
      Serializers::ReservationTypeSerializer     => 'yml',
      Serializers::CategorySerializer            => 'yml',
      Serializers::TopicSerializer               => 'yml',
      Serializers::CustomModelTypeSerializer     => 'yml',
      Serializers::WorkflowSerializer            => 'yml',

      Serializers::PageSerializer          => 'liquid',
      Serializers::ContentHolderSerializer => 'liquid',
      Serializers::MailerSerializer        => 'liquid',
      Serializers::SmsSerializer           => 'liquid',
      Serializers::LiquidViewSerializer    => 'liquid',

      Serializers::GraphQuerySerializer => 'graphql'
    }

    def initialize(instance_id, destination_path)
      @instance_id = instance_id
      @destination_path = destination_path
    end

    def execute!
      AVAILABLE_SERIALIZERS_LIST.each do |serializer_class, file_extension|
        results = serializer_class.new(instance).export
        create_exported_files results, file_extension
      end
    end

    private

    def create_exported_files(files_to_create, extension)
      files_to_create.each do |file_to_create|
        ensure_directory_exist! file_to_create[:resource_name]
        create_file_with_content! file_to_create, extension
      end
    end

    def ensure_directory_exist!(file_path)
      dir_path = File.dirname file_path
      FileUtils.mkdir_p "#{@destination_path}/#{@instance.name}/#{dir_path}"
    end

    def create_file_with_content!(file, extension)
      File.open("#{@destination_path}/#{@instance.name}/#{file[:resource_name]}.#{extension}", 'w') do |f|
        raw_content = file[:exported_data].delete('content')

        if file[:exported_data].present?
          f.write file[:exported_data].to_yaml
          f.puts '---' if raw_content.present?
        end

        f.write raw_content
      end
    end

    def instance
      @instance ||= Instance.find_by id: @instance_id
    end
  end
end
