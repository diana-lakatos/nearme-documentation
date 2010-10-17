module GmapsFake

  def stub_requests
    WebMock.stub_request(:get, %r|.*maps\.google\.com.*| ).to_return({:body => File.read(File.join(Rails.root, *%w[features fixtures gmaps generic.json]))})
  end

  extend self

end
