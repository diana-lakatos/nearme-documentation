require 'vcr'

VCR.configure do |c|  
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'assets', 'vcr_cassettes')
  c.hook_into :webmock
  c.debug_logger = File.open(File.join(File.dirname(__FILE__), '..', 'log', 'vcr_debug.log'), 'w')
  c.default_cassette_options = { :match_requests_on => [ :body ], :serialize_with => :yaml }
  c.ignore_hosts 'codeclimate.com'
end
