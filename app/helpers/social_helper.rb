module SocialHelper
  def share_to_facebook(url, options = {})
    icon = options[:icon].presence || 'facebook'
    url = "'//www.facebook.com/sharer/sharer.php?u='+encodeURIComponent('#{j(url)}')"
    social_share('facebook', url, 626, 436, icon)
  end

  def share_to_twitter(url, options = {})
    icon = options[:icon].presence || 'twitter'
    text = options[:text]
    url = "'//twitter.com/share?url='+encodeURIComponent('#{j(url)}')"
    url << "+'&text='+encodeURIComponent('#{j(text)}')" if text
    social_share('twitter', url, 626, 260, icon)
  end

  def share_to_linkedin(url, options = {})
    icon = options[:icon].presence || 'linkedin'
    text = options[:text]
    url = "'//www.linkedin.com/shareArticle?url='+encodeURIComponent('#{j(url)}')"
    url << "+'&title='+encodeURIComponent('#{j(text)}')" if text
    social_share('linkedin', url, 626, 260, icon)
  end

  def share_to_google_plus(url, options = {})
    icon = options[:icon].presence || 'google-plus'
    url = "'//plus.google.com/share?url='+encodeURIComponent('#{j(url)}')"
    social_share('google-plus', url, 626, 260, icon)
  end

  def share_to_mail(subject, body)
    mail_to('', '', subject: subject, body: body, class: 'ico-mail')
  end

  def share_to_clipboard(url)
    link_to('', url, class: 'ico-link', data: { 'clipboard-text' => url })
  end

  private

  def social_share(network, url, width, height, icon)
    raw %{<a href="#" class="ico-#{icon}" onclick="window.open(#{url}, '#{network}-share-dialog', 'width=#{width},height=#{height}'); return false;"></a>}
  end
end
