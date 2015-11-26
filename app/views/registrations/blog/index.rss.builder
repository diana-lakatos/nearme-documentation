xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title blog_rss_title
    xml.link blog_rss_url

    for post in @blog_posts
      xml.item do
        xml.title post.title
        xml.description strip_tags(post.content)
        xml.pubDate post.published_at.to_s(:rfc822)
        xml.link blog_rss_post_url(post)
        xml.guid blog_rss_post_url(post)
      end
    end
  end
end
