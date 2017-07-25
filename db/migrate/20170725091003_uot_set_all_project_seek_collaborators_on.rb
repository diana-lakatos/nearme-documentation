class UotSetAllProjectSeekCollaboratorsOn < ActiveRecord::Migration
  def change
    Instances::InstanceFinder.get(:uot).each do |instance|
      instance.set_context!

      Transactable.update_all(seek_collaborators: true)
    end
  end
end
