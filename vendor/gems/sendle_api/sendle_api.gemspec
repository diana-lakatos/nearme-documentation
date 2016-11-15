Gem::Specification.new do |spec|
  spec.name        = 'sendle_api'
  spec.version     = '0.0.1'
  spec.date        = '2016-09-28'
  spec.summary     = 'Sendle API Ruby Client'
  spec.description = 'Sendle API Ruby Client'
  spec.authors     = ['Dariusz Gorzeba']
  spec.email       = 'darek@near-me.com'
  spec.files       = ['lib/sendle_api.rb','lib/sendle_api/client.rb']
  spec.license     = 'MIT'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'unf_ext'
end
