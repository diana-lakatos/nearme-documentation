require 'sprockets/rails/task'
# clean the old tasks
Rake::Task["assets:precompile"].clear
Sprockets::Rails::Task.new(Rails.application) do |t|
  t.manifest = lambda do
    app = Rails.application
    Sprockets::Manifest.new(app.assets, File.join(app.root, 'public', app.config.assets.prefix, 'manifest.json'))
  end
end
