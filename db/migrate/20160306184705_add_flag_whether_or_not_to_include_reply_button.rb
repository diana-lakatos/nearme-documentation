class AddFlagWhetherOrNotToIncludeReplyButton < ActiveRecord::Migration
  def change
    add_column :instances, :enable_reply_button_on_host_reservations, :boolean, default: false
  end
end
