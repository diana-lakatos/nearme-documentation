require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = File.join(Rails.root, 'features', 'vcr_cassettes')
  # c.debug_logger = File.open(File.join(Rails.root, 'features', 'log', 'vcr.log'), 'w')
  c.hook_into :webmock
  c.default_cassette_options = { match_requests_on: [:body], serialize_with: :yaml }
  c.allow_http_connections_when_no_cassette = true
  c.ignore_hosts 'codeclimate.com'
  c.ignore_localhost = true
  c.default_cassette_options = { :record => :new_episodes }
end

# INFO: https://github.com/myronmarston/vcr/wiki/Usage-with-Cucumber
VCR.cucumber_tags do |t|
  t.tag  '@localhost_request'
  t.tag  '@offer_flow'
end
