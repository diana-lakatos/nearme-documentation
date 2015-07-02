class AddAllowVideoEmbedsToBlogInstance < ActiveRecord::Migration
  def change
    add_column :blog_instances, :allow_video_embeds, :boolean, :default => false
  end
end
