class InstanceAdmin::Manage::MarketplaceBuilderImportService
  def initialize(file)
    @file = file
  end

  def call
    save_file_to_tmp
    unzip_file
    load_marketplace
  ensure
    cleanup_after_import
  end

  protected

  def save_file_to_tmp
    File.open("tmp/#{zip_file_name}.zip", "wb") { |f| f.write(@file.read) }
  end

  def unzip_file
    system "cd tmp; unzip #{zip_file_name}.zip -d #{zip_file_name} "
  end

  def load_marketplace
    MarketplaceBuilder::Loader.load "tmp/#{zip_file_name}/#{PlatformContext.current.instance.name}/"
  end

  def cleanup_after_import
    FileUtils.rm_rf "tmp/#{zip_file_name}"
  end

  private

  def zip_file_name
    @zip_file_name ||= "instance-import-#{DateTime.now.to_i}"
  end
end
