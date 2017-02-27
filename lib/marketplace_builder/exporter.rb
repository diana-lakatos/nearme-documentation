require 'open-uri'

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
      Serializers::RatingSystemSerializer        => 'yml',

      Serializers::PageSerializer          => 'liquid',
      Serializers::ContentHolderSerializer => 'liquid',
      Serializers::MailerSerializer        => 'liquid',
      Serializers::SmsSerializer           => 'liquid',
      Serializers::LiquidViewSerializer    => 'liquid',

      Serializers::GraphQuerySerializer  => 'graphql',
      Serializers::CustomThemeSerializer => 'theme_with_assets'
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

      create_mpbuilderrc_file
    end

    private

    def create_exported_files(files_to_create, extension)
      files_to_create.each do |file_to_create|
        ensure_directory_exist! file_to_create[:resource_name]
        if extension != 'theme_with_assets'
          create_file_with_content! file_to_create, extension
        else
          create_theme_files! file_to_create
        end
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

    def create_theme_files!(exported_hash)
      custom_theme_assets = exported_hash[:exported_data].delete('custom_theme_assets')
      create_file_with_content! exported_hash, 'yml'

      FileUtils.mkdir_p "#{@destination_path}/#{@instance.name}/#{exported_hash[:resource_name]}_custom_theme_assets/"
      create_assets!(exported_hash[:resource_name], custom_theme_assets) if custom_theme_assets
    end

    def create_assets!(theme_name, custom_theme_assets)
      custom_theme_assets.each do |asset|
        download_and_save_asset(theme_name, asset)
      end
    end

    def download_and_save_asset(theme_name, asset)
      open(asset['remote_url']) do |downloaded_asset|
        IO.copy_stream(downloaded_asset, "#{@destination_path}/#{@instance.name}/#{theme_name}_custom_theme_assets/#{asset['name']}")
      end
    rescue OpenURI::HTTPError => e
      puts "Error while downloading #{asset['remote_url']} status: #{e.io.status}"
    rescue Exception => e
      puts "Error: #{e.message}"
    end

    def create_mpbuilderrc_file
      File.open("#{@destination_path}/#{@instance.name}/.mpbuilderrc", "w") do |f|
        f.write(JSON.pretty_generate({instance_id: @instance_id, mode: 'append'}))
      end
    end

    def instance
      @instance ||= Instance.find_by id: @instance_id
    end
  end
end
