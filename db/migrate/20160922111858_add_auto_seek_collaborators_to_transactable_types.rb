class AddAutoSeekCollaboratorsToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :auto_seek_collaborators,:boolean, default: false

    instance = Instance.find_by(id: 198)
    return if instance.nil?

    TransactableType.reset_column_information

    instance.set_context!
    TransactableType.update_all(auto_seek_collaborators: true)
    Transactable.update_all(seek_collaborators: true)
  end
end
