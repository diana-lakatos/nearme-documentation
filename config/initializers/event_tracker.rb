Rails.application.config.event_tracker = Rails.env.test? ? ::EventTracker::NullTracker : ::EventTracker::BaseTracker
