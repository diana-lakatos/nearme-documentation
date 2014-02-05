class AddRedirectUrlAndOpenInNewWindowToPage < ActiveRecord::Migration
  def change
    add_column :pages, :redirect_url, :string
    add_column :pages, :open_in_new_window, :boolean, default: true
  end
end
