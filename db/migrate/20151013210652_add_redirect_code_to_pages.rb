class AddRedirectCodeToPages < ActiveRecord::Migration
  def change
    add_column :pages, :redirect_code, :integer
  end
end
