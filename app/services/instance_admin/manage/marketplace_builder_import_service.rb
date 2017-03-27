# frozen_string_literal: true
class InstanceAdmin::Manage::MarketplaceBuilderImportService
  def initialize(file)
    @file = file
  end

  def call
    save_file_to_tmp
    unzip_file
    sanity_check!
    load_marketplace
  ensure
    cleanup_after_import
  end

  protected

  def save_file_to_tmp
    File.open("tmp/#{zip_file_name}.zip", 'wb') { |f| f.write(@file.read) }
  end

  def unzip_file
    system "cd tmp; unzip #{zip_file_name}.zip -d #{zip_file_name} "
  end

  def sanity_check!
    ensure_proper_instance_id_in_mpbuilderrc!
  end

  def load_marketplace
    MarketplaceBuilder::Loader.load marketplace_folder_path
  end

  def cleanup_after_import
    FileUtils.rm_rf "tmp/#{zip_file_name}"
  end

  private

  def ensure_proper_instance_id_in_mpbuilderrc!
    config = JSON.parse(File.read("#{marketplace_folder_path}/.mpbuilderrc"))
    raise 'Invalid instance_id in mpbuilderrc file!' unless config['instance_id'] == PlatformContext.current.instance.id
  end

  def marketplace_folder_path
    @path ||= Dir.glob("tmp/#{zip_file_name}/*").find { |e| File.directory?(e) }
  end

  def zip_file_name
    @zip_file_name ||= "instance-import-#{DateTime.now.to_i}"
  end
end
