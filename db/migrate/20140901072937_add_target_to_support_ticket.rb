class AddTargetToSupportTicket < ActiveRecord::Migration
  class Support::Ticket < ActiveRecord::Base
    self.table_name = 'support_tickets'
  end

  def change
    change_table :support_tickets do |t|
      t.references :target, polymorphic: true, index: true
      t.text :reservation_details
    end
    Support::Ticket.where(target_id: nil).find_each do |t|
      t.target_id = t.instance_id
      t.target_type = 'Instance'
      t.save!
    end
  end

end
