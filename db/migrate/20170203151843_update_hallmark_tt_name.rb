class UpdateHallmarkTtName < ActiveRecord::Migration
  def up
    i = Instance.find_by(id: 5011)
    return true if i.nil?
    i.set_context!
    Translation.where(value: '%DIY%', instance_id: 5011).each do |t|
      new_value = t.value.gsub('DIY', 'Share')
      puts "Updating #{t.value} to #{new_value}"
      t.update_attribute(:value, new_value)
    end
    Page.find_each do |p|
      p.update_attribute(:html_content, p.html_content.gsub('DIY', 'Share'))
    end
    InstanceView.find_each do |iv|
      iv.update_attribute(:body, iv.body.gsub('DIY', 'Share'))
    end
    Translation.where(key: 'project', instance_id: 5011).first&.update_attribute(:value, 'Share')
    tt = TransactableType.where(name: 'DIY').first
    return true if tt.nil?
    puts "Updating TT for Hallmark"
    tt.name = 'Share'
    tt.slug = 'share'
    tt.bookable_noun = 'Share'
    tt.save!
  end

  def down
  end
end
