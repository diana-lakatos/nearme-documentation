require 'video_info'

class VideoEmbedder
  include ActiveModel::Model

  attr_reader :video_info

  validate :video_availavility

  def initialize(url, embed_options = {})
    @video_info = VideoInfo.new(url) rescue nil
    @embed_options = embed_options
  end

  def video_url
    video_info.try(:url)
  end

  def html
    return '' if @video_info.try(:embed_code).blank?
    "<div class=\"video-wrapper #{@video_info.provider.downcase}\"><div class=\"video-constrainer\">#{@video_info.embed_code(@embed_options)}</div></div>"
  end

  private

  def video_availavility
    errors.add(:video_url, I18n.t('custom_errors.video_url_not_supported')) unless @video_info.try(:available?)
  end
end
