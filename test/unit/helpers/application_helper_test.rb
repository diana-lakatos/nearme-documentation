require 'test_helper'
require 'action_view/test_case'

class ApplicationHelperTest < ActionView::TestCase
  include Devise::TestHelpers

  test 'truncate with elipsis handles nil body' do
    assert_equal '', truncate_with_ellipsis(nil, 10)
  end

  test 'truncate with elipsis works' do
    assert_equal "<p><span class=\"truncated-ellipsis\">&hellip;</span><span class=\"truncated-text hidden\">0123456789 the rest should be truncated</span></p>", truncate_with_ellipsis("0123456789 the rest should be truncated", 10)
  end

end
