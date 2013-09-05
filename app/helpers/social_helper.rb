module SocialHelper
  def share_to_facebook(url)
    url = "'//www.facebook.com/sharer/sharer.php?u='+encodeURIComponent('#{j(url)}')"
    social_share(:facebook, url, 626, 436)
  end

  def share_to_twitter(url)
    url = "'//twitter.com/share?url='+encodeURIComponent('#{j(url)}')"
    social_share(:twitter, url, 626, 260)
  end

  def share_to_linkedin(url)
    url = "'//www.linkedin.com/cws/share?url='+encodeURIComponent('#{j(url)}')"
    social_share(:linkedin, url, 626, 260)
  end

  def share_to_mail(subject, body)
    mail_to('', '', subject: subject, body: body, class: 'ico-mail')
  end

  def share_to_clipboard(url)
    link_to('', url, class:"ico-link", data: {'clipboard-text' => url})
  end

  private

  def social_share(network, url, width, height)
    raw %{<a href="#" class="ico-#{network}" onclick="window.open(#{url}, '#{network}-share-dialog', 'width=#{width},height=#{height}'); return false;"></a>}
  end
end
