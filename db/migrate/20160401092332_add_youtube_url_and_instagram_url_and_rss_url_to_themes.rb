class AddYoutubeUrlAndInstagramUrlAndRssUrlToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :youtube_url, :string
    add_column :themes, :rss_url, :string
  end
end
