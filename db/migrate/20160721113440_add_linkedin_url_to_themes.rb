class AddLinkedinUrlToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :linkedin_url, :string
  end
end
