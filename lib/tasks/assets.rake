namespace :assets do
  desc "Copy manifest file from config/ to config.assets.prefix"
  task :move_manifest=> [:environment] do
    FileUtils.mv(File.join(Rails.root, "config", "manifest.json"),
                 File.join(Rails.root, "public", Rails.application.config.assets.prefix))
  end
end
