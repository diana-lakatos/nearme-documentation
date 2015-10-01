class AddIpAddressToSpamReports < ActiveRecord::Migration
  def change
    add_column :spam_reports, :ip_address, :string
  end
end
