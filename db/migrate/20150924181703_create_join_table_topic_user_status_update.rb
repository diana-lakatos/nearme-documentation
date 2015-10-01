class CreateJoinTableTopicUserStatusUpdate < ActiveRecord::Migration
  def change
    create_join_table :topics, :user_status_updates do |t|
      t.index [:topic_id, :user_status_update_id], name: :topic_usu_id
      t.index [:user_status_update_id, :topic_id], name: :usu_topic_id
    end
  end
end
