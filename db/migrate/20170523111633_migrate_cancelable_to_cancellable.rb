class MigrateCancelableToCancellable < ActiveRecord::Migration
  def up
    FormConfiguration.where("liquid_body LIKE '%.cancelable?%'").each do |fc|
      fc.liquid_body.gsub!('.cancelable?', '.cancellable?')
      fc.save!
    end

    InstanceView.where("body LIKE '%.cancelable?%'").each do |iv|
      iv.update_column(:body, iv.body.gsub('.cancelable?', '.cancellable?'))
    end
  end
end
