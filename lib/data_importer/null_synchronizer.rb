class DataImporter::NullSynchronizer

  attr_accessor :company

  def initialize(*args)
  end

  def mark_all_object_to_delete!
  end

  def delete_active_record_relation!(relation)
    0
  end

  def unmark_object(object)
    object
  end

  def unmark_object!(object)
  end

  def performing_real_operations?
    false
  end

end

