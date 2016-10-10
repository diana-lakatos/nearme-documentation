class EventTracker::NullTracker < EventTracker::BaseTracker
  def initialize(*_args)
  end

  def track_charge(*_objects)
  end

  def triggered_client_taggable_methods(*_args)
    []
  end

  def pixel_track_url(*_args)
    "<img src='http://www.example.com' width='1' height='1'>"
  end

  def apply_user(*_args)
  end

  private

  def track(*_args)
  end

  def set_person_properties(*_args)
  end
end
