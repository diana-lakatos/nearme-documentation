module PlatformHome::PlatformHomeHelper

  def host
    "#{request.scheme}://#{request.host}"
  end

  def twitter_share_url
    "https://twitter.com/intent/tweet?status=#{CGI::escape("Check out @NearMeCo, a new platform for creating peer-to-peer marketplaces #sharingeconomy #collcons #{host}")}"
  end

  def linkedin_share_url
    sharing_title = CGI::escape('Near Me | Get in the Business of Sharing')
    sharing_description = CGI::escape('Near Me is a new platform for creating peer-to-peer marketplaces: empower any sharing ecosystem you can imagine.')
    "http://www.linkedin.com/shareArticle?mini=true&title=#{sharing_title}&summary=#{sharing_description}&url=#{CGI::escape(host)}"
  end

  def facebook_share_url
    sharing_title = CGI::escape('Near Me | Get in the Business of Sharing')
    sharing_description = CGI::escape('Near Me is a new platform for creating peer-to-peer marketplaces: empower any sharing ecosystem you can imagine.')
    "http://www.facebook.com/sharer.php?s=100&p[url]=#{host}&p[images][0]=#{CGI::escape("#{host}/assets/logo.jpg")}&p[title]=#{sharing_title}&p[summary]=#{sharing_description}"
  end

  def gplus_share_url
    "https://plus.google.com/share?url=#{host}"
  end

  def sticky_footer?
    request.path.include?('/get-in-touch') || request.path.include?('/unsubscribe') || request.path.include?('/resubscribe')
  end

  def main_container_css_class
    sticky_footer? ? 'sticky-footer' : ''
  end

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : nil

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end

end
