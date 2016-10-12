class DataImporter::Tracker::ProgressTracker < DataImporter::Tracker
  class Updater
    def initialize(data_upload)
      @data_upload = data_upload
      @current_progress = 0
    end

    def update(progress)
      if progress > @current_progress
        @current_progress = progress
        update!
      end
    end

    protected

    def update!
      @data_upload.update_column(:progress_percentage, @current_progress)
    end
  end

  def initialize(data_upload, total_objects_count)
    @updater = Updater.new(data_upload)
    @total_objects_count = total_objects_count
    @total_objects_processed = 0
  end

  def object_created(object, *_args)
    object_processed(object)
  end

  def object_not_created(object, *_args)
    object_processed(object)
  end

  def object_valid(object, *_args)
    object_processed(object)
  end

  def object_not_valid(object, *_args)
    object_processed(object)
  end

  protected

  def object_processed(object)
    if is_relevant_object?(object)
      @total_objects_processed += 1
      @updater.update((@total_objects_processed.to_f * 100 / @total_objects_count.to_f).floor)
    end
  end

  def is_relevant_object?(object)
    case object
    when Location, Transactable, Photo, 'photo'
      true
    else
      false
    end
  end
end
