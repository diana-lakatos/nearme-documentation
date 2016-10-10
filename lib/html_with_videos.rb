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
    video_info = VideoInfo.new(url) rescue nil
    if video_info.try(:embed_code).present?
      width = @embed_options[:iframe_width] || 480
      height = @embed_options[:iframe_height] || 270

      return "<div class=\"video-wrapper #{video_info.provider.downcase}\"><div class=\"video-constrainer\">#{video_info.embed_code(iframe_attributes: { width: width, height: height })}</div></div>"
    end

    nil
  end
end
