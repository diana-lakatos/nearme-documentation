require 'test_helper'

class ErrorPagesTest < ActionDispatch::IntegrationTest
  setup do
    create(:domain, target: PlatformContext.current.instance, name: 'near-me.com')
  end

  test 'Redirect to near-me.com if domain not configured' do
    get_via_redirect 'http://test.example.info'
    assert_equal 200, status
    assert_equal '/', path
  end
end
