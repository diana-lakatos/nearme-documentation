class AddRingToneToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :twilio_ring_tone, :string
  end
end
