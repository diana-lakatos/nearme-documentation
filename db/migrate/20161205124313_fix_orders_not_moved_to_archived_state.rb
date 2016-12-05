class FixOrdersNotMovedToArchivedState < ActiveRecord::Migration
  def self.up
    Instance.find_each do |instance|
      instance.set_context!
      puts "At instance #{instance.name}"

      index = 0
      Order.find_each do |order|
        if order.type != 'DelayedReservation'
          if order.state == 'confirmed' && order.ends_at.present? && order.ends_at < Time.now && order.archived_at.blank?
            puts "At index #{index}" if index % 50 == 0
            order.mark_as_archived!

            index += 1
          end
        end
      end
    end
  end

  def self.down
  end
end
