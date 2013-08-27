MIXPANEL_SETTINGS = (YAML.load_file(Rails.root.join("config", "mixpanel_settings.yml"))[Rails.env] || {}).with_indifferent_access
