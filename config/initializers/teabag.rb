Teabag.setup do |config|

  config.mount_at = "/teabag"
  config.root = nil
  config.asset_paths = ["spec/javascripts", "spec/javascripts/stylesheets"]
  config.fixture_path = "spec/javascripts/fixtures"
  config.suite do |suite|
    suite.matcher = "{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"
    suite.helper = "spec_helper"
    suite.javascripts = ["teabag-jasmine"]
    suite.stylesheets = ["teabag"]
  end

end if defined?(Teabag) && Teabag.respond_to?(:setup) # let Teabag be undefined outside of development/test/asset groups
