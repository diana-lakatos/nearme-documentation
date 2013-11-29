class AddSkipCompanyToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :skip_company, :boolean, default: false
  end
end
