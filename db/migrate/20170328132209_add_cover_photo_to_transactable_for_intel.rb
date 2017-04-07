class AddCoverPhotoToTransactableForIntel < ActiveRecord::Migration
  def up
    Instance.transaction do
      Instances::InstanceFinder.get(:devmesh).each do |i|
        i.set_context!

        TransactableType.where(name: 'Project').each do |tt|
          tt.custom_attributes.where(name: 'cover_photo').first_or_create!(attribute_type: 'photo')
        end

        query_string = <<EOQ
query TransactableCoverPhotoQuery($transactable_id: ID!){
  transactable(id: $transactable_id) {
    cover_photos: custom_attribute_photos(name: "cover_photo"){
      url: url(version: "normal")
    }
  }
}
EOQ
        i.graph_queries.create!(
          name: 'transactable_cover_photos',
          query_string: query_string
        )
      end
    end
  end

  def down
    Instances::InstanceFinder.get(:devmesh).each do |i|
      i.set_context!

      TransactableType.where(name: 'Project').each do |tt|
        tt.custom_attributes.where(name: 'cover_photo').delete_all
      end
      i.graph_queries.where(name: 'transactable_cover_photos').delete_all
    end
  end
end
