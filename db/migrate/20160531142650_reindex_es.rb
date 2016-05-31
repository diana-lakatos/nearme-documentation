class ReindexEs < ActiveRecord::Migration
  def up
    PlatformContext.clear_current
    Transactable.__elasticsearch__.create_index! force: true
    Transactable.searchable.import force: true
  end
end
