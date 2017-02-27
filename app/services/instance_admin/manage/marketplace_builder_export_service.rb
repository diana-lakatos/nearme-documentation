class InstanceAdmin::Manage::MarketplaceBuilderExportService
  def initialize(send_data_function)
    @send_data_function = send_data_function
  end

  def call
    export_current_instance_to_tmp_folder
    zip_exported_folder
    call_send_data_function
  ensure
    cleanup_after_export
  end

  protected

  def export_current_instance_to_tmp_folder
    MarketplaceBuilder::Exporter.new(PlatformContext.current.instance.id, export_folder_path).execute!
  end

  def zip_exported_folder
    system "cd #{export_folder_path}; zip -r #{current_instance_name}.zip #{current_instance_name}"
  end

  def call_send_data_function
    File.open("#{export_folder_path}/#{current_instance_name}.zip", 'r') do |f|
      @send_data_function.call f
    end
  end

  def cleanup_after_export
    FileUtils.rm_rf(export_folder_path)
  end

  private

  def current_instance_name
    @current_instance_name ||= PlatformContext.current.instance.name
  end

  def export_folder_path
    @export_folder_path ||= "tmp/#{current_instance_name}-#{DateTime.now.to_i}"
  end
end
