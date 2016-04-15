class VideoEmbedder

  def initialize(url)
    @video_info = VideoInfo.new(url) rescue nil
  end


  def html
    return '' if @video_info.try(:embed_code).blank?
    "<div class=\"video-wrapper #{@video_info.provider.downcase}\"><div class=\"video-constrainer\">#{@video_info.embed_code}</div></div>"
  end
end

