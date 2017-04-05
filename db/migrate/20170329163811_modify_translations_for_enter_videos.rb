class ModifyTranslationsForEnterVideos < ActiveRecord::Migration
  def self.up
    Translation.unscoped.where(key: 'simple_form.placeholders.group.video_url').update_all(value: 'Enter YouTube, Vimeo or Facebook video URL')
  end

  def self.down
    Translation.unscoped.where(key: 'simple_form.placeholders.group.video_url').update_all(value: 'Enter YouTube or Vimeo video URL')
  end
end
