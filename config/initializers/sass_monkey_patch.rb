module Sass::Script::Functions
  def cachebust_generated_images
    generated_images_path = Rails.root.join(Compass.configuration.generated_images_dir).to_s
    sprockets_entries = options[:sprockets][:environment].send(:trail).instance_variable_get(:@entries)
    sprockets_entries.delete(generated_images_path) if sprockets_entries && sprockets_entries.has_key?(generated_images_path)
  end
end
