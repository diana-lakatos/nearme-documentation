class EventTracker::NullTracker < EventTracker::BaseTracker

  def initialize(*args)
  end

  def track_charge(*objects)
  end

  def triggered_client_taggable_methods(*args)
    []
  end

  def pixel_track_url(*args)
    "<img src='http://www.example.com' width='1' height='1'>"
  end

  def apply_user(*args)
  end

  private

  def track(*args)
  end

  def set_person_properties(*args)
  end

end

