class DataImporter::NullSynchronizer
  attr_accessor :company

  def initialize(*_args)
  end

  def mark_all_object_to_delete!
  end

  def delete_active_record_relation!(_relation)
    0
  end

  def unmark_object(object)
    object
  end

  def unmark_object!(_object)
  end

  def performing_real_operations?
    false
  end
end
