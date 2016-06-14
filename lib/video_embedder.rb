class VideoEmbedder

  def initialize(url, embed_options = {})
    @video_info = VideoInfo.new(url) rescue nil
    @embed_options = embed_options
  end


  def html
    return '' if @video_info.try(:embed_code).blank?
    "<div class=\"video-wrapper #{@video_info.provider.downcase}\"><div class=\"video-constrainer\">#{@video_info.embed_code(@embed_options)}</div></div>"
  end
end

