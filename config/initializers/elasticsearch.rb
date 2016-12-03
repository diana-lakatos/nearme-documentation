config = {
  host: 'http://localhost:9200',
  transport_options: {
    request: { timeout: 35 }
  }
}

if File.exist?('config/elasticsearch.yml')
  elastic_config = YAML.load_file('config/elasticsearch.yml').deep_symbolize_keys
  env_config = elastic_config[Rails.env.to_sym]
  config = config.merge!(env_config) if env_config.present?
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
