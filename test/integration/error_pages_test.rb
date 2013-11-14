require "test_helper"

class ErrorPagesTest < ActionDispatch::IntegrationTest

  test "Display information page if domain not configured" do
    get_via_redirect 'http://test.example.info'
    assert_equal 404, status
    assert_equal '/domain-not-configured', path
  end

end
