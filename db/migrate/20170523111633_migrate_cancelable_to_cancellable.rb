class MigrateCancelableToCancellable < ActiveRecord::Migration
  def up
    FormConfiguration.where("liquid_body LIKE '%.cancelable?%'").each do |fc|
      fc.liquid_body.gsub!('.cancelable?', '.cancellable?')
      fc.save!
    end

    InstanceView.where("body LIKE '%.cancelable?%'").each do |iv|
      iv.body.gsub!('.cancelable?', '.cancellable?')
      iv.save!
    end
  end
end
