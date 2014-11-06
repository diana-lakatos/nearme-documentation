class AddRedirectToToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :redirect_to, :string
    add_column :domains, :redirect_code, :integer
  end
end
