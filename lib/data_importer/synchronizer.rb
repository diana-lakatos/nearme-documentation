class DataImporter::Synchronizer
  attr_accessor :company

  def performing_real_operations?
    true
  end

  def mark_all_object_to_delete!
    if @company.persisted?
      @company.locations.update_all(mark_to_be_bulk_update_deleted: true)
      @company.listings.update_all(mark_to_be_bulk_update_deleted: true)
      @company.photos.update_all(mark_to_be_bulk_update_deleted: true)
    end
  end

  def delete_active_record_relation!(relation)
    relation.where(mark_to_be_bulk_update_deleted: true).destroy_all.count
  end

  def unmark_object(object)
    object.mark_to_be_bulk_update_deleted = false
    object
  end

  def unmark_object!(object)
    object.update_column(:mark_to_be_bulk_update_deleted, false) if object.persisted?
  end
end
