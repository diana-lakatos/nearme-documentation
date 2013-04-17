class Track

  def self.analytics
    @analytics ||= Analytics.new
  end

  class List

  end

  class Book

  end

  class User

  end

  class Search

    def self.viewed_a_location(properties)
      Track.analytics.track('Viewed a Location', {
        logged_in: properties[:user_signed_in],
        location_suburb: properties[:location]['suburb'],
        location_city: properties[:location]['city'],
        location_state: properties[:location]['state'],
        location_country: properties[:location]['country']
      })
    end

  end

end
