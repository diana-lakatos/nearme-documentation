# frozen_string_literal: true
require 'minitest/reporters'
require 'minitest-vcr'
Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)
require 'minitest/autorun'

require './test/factories'

MinitestVcr::Spec.configure!

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
end

module SendleClientSupport
  def client
    SendleApi::Client.new sendle_id: 'darek_near_me_com', sendle_api_key: 'BBXmdgVKwxy4Yvz5yCRrJjSX'
  end
end
