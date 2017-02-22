if ENV['COVERAGE'] == 'on'
  SimpleCov.start 'rails' do
      add_group 'Serializers', 'app/serializers'
      add_group 'Mailers', 'app/mailers'
      add_group 'Widgets', 'app/widgets'
      add_group 'Inputs', 'app/inputs'
      add_group 'Uploaders', 'app/uploaders'
      add_group 'Drops', 'app/drops'
      add_group 'Decorators', 'app/decorators'
      add_group 'Jobs', 'app/jobs'
  end

  require 'simplecov-rcov-text'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovTextFormatter
  ]

  SimpleCov.merge_timeout 3600
end
