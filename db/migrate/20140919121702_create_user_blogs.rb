class CreateUserBlogs < ActiveRecord::Migration

  class UserBlog < ActiveRecord::Base
  end

  def change
    create_table :user_blogs do |t|
      t.integer :user_id
      t.boolean :enabled, default: false
      t.string :name
      t.string :header_image
      t.string :header_text
      t.string :header_motto
      t.string :header_logo
      t.string :header_icon
      t.string :facebook_app_id

      t.timestamps
    end

    reversible do
      User.all.each { |user| UserBlog.create(user_id: user.id) }
    end
  end
end
