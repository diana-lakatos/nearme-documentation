class DisableSearchForTtInUot < ActiveRecord::Migration
  def up
    instance = Instance.find_by(id: 195)
    return unless instance
    instance.set_context!
    TransactableType.all.each do |tt|
      tt.searchable = false
      tt.save!
    end
  end
end
