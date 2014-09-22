class AddBalancerParamsToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :state, :string
    add_column :domains, :load_balancer_name, :string
    add_column :domains, :server_certificate_name, :string
    add_column :domains, :error_message, :string
    add_column :domains, :dns_name, :string
  end
end
