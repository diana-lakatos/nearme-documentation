require 'video_info'

class HtmlWithVideos < Redcarpet::Render::HTML
  def initialize(options = {}, embed_options = {})
    @embed_options = embed_options
    super options
  end

  def link(link, _title, content)
    video_embed = get_video_embed(link)
    if video_embed.present?
      video_embed
    else
      "<a href='#{link}'>#{content}</a>"
    end
  end

  def autolink(link, _link_type)
    video_embed = get_video_embed(link)
    if video_embed.present?
      video_embed
    else
      "<a href='#{link}'>#{link}</a>"
    end
  end

  def get_video_embed(url)
    width = @embed_options[:iframe_width] || 480
    height = @embed_options[:iframe_height] || 270

    video_embedder = Videos::VideoEmbedder.new(url, iframe_attributes: { width: width, height: height })

    if video_embedder.html.present?
      video_embedder.html
    else
      nil
    end
  end
end
