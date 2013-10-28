class AddGplusUrlToTheme < ActiveRecord::Migration
  def change
    add_column :themes, :gplus_url, :string
  end
end
