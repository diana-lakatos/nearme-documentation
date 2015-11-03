module Thumbnable
  extend ActiveSupport::Concern

  def url_thumb
    @url_thumb ||= Ckeditor::Utils.filethumb(filename)
  end
end
