require 'test_helper'

class SocialHelperTest < ActionView::TestCase
  setup do
    @url = "http://test.url"
  end

  test "#share_to_twitter" do
    result = share_to_twitter(@url)
    expected = %{<a href="#" class="ico-twitter" onclick="window.open('//twitter.com/share?url='+encodeURIComponent('#@url'), 'twitter-share-dialog', 'width=626,height=260'); return false;"></a>}
    assert_equal expected, result
  end

  test "#share_to_facebook" do
    result = share_to_facebook(@url)
    expected = %{<a href="#" class="ico-facebook" onclick="window.open('//www.facebook.com/sharer/sharer.php?u='+encodeURIComponent('#@url'), 'facebook-share-dialog', 'width=626,height=436'); return false;"></a>}
    assert_equal expected, result
  end

  test "#share_to_linkedin" do
    result = share_to_linkedin(@url)
    expected = %{<a href="#" class="ico-linkedin" onclick="window.open('//www.linkedin.com/shareArticle?url='+encodeURIComponent('#@url'), 'linkedin-share-dialog', 'width=626,height=260'); return false;"></a>}
    assert_equal expected, result
  end

  test "#share_to_mail" do
    result = share_to_mail("Subject", @url)
    expected = %{<a class="ico-mail" href="mailto:?body=http%3A%2F%2Ftest.url&amp;subject=Subject"></a>}
    assert_equal expected, result
  end

  test "#share_to_clipboard" do
    result = share_to_clipboard(@url)
    expected = %{<a href="#@url" class="ico-link" data-clipboard-text="#@url"></a>}
    assert_equal expected, result
  end
end
