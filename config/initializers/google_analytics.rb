GOOGLE_ANALYTICS_SETTINGS = (YAML.load_file(Rails.root.join("config", "google_analytics.yml"))[Rails.env] || {}).with_indifferent_access
