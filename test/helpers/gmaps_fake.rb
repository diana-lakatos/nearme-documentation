module GmapsFake

  extend self

  def stub_requests
    WebMock.stub_request(:get, %r|.*maps\.googleapis\.com.*| ).to_return { |request| match_query(request) }
  end

  private

    def match_query(request)
      address = request.uri.query_values['address']
      file = case request.uri.query_values['address']
        when /adelaide/i then "adelaide"
        when /chicago/i then "chicago"
        when /craigmore/i then "craigmore"
        when /darwin/i then "darwin"
        when /launceston/i then "launceston"
        when /usa/i then "usa"
        when /australia/i then "australia"
        when /auckland/i then "auckland"
        when /new zealand/i then "new_zealand"
        when /bung/i then return { :status => 404 }
        when /desks near me/i then return { :status => 404 }
        when /cave of awesome/i then return { :status => 404 }
        else raise StandardError, "Define a place for #{address} (#{request.uri})"
      end
      { :body => File.read(File.join(Rails.root, "features", "fixtures", "gmaps", "#{file}.json")) }
    end

end
