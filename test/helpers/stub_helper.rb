module StubHelper

  def stub_mixpanel
    stub_request(:get, /.*api\.mixpanel\.com.*/)
    @tracker = Analytics::EventTracker.any_instance
  end

  def stub_image_url(image_url)
    stub_request(:get, image_url).to_return(:status => 200, :body => Rails.root.join("test", "assets", "foobear.jpeg"), :headers => {'Content-Type' => 'image/jpeg'})
  end

  def stub_local_time_to_return_hour(target, hour)
    time = mock()
    time.stubs(:hour).returns(hour)
    target.stubs(:local_time).returns(time)
  end

end
