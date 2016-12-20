# frozen_string_literal: true
module GmapsFake
  extend self

  def stub_requests
    WebMock.stub_request(:get, /.*maps\.googleapis\.com.*/).to_return { |request| match_query(request) }
  end

  private

  def match_query(request)
    address = request.uri.query_values['address']
    file = case request.uri.query_values['address']
           when /1600 Amphitheatre Parkway, Mountain View, CA 94043, USA/i then 'mountain_view'
           when /adelaide/i then 'adelaide'
           when /chicago/i then 'chicago'
           when /craigmore/i then 'craigmore'
           when /darwin/i then 'darwin'
           when /launceston/i then 'launceston'
           when /usa/i then 'usa'
           when /australia/i then 'australia'
           when /auckland/i then 'auckland'
           when /bung/i then return { status: 404, body: '{}' }
           when /desks near me/i then return { status: 404, body: '{}' }
           when /cave of awesome/i then return { status: 404, body: '{}' }
           when /ursynowska/i then 'ursynowska'
           when /pulawska/i then 'pulawska'
           when /czestochowa/i then 'czestochowa'
           when /rydygiera/i then 'rydygiera'
           when /United States/i then 'usa'
           else raise StandardError, "Define a place for #{address} (#{request.uri})"
    end
    { body: File.read(File.join(Rails.root, 'features', 'fixtures', 'gmaps', "#{file}.json")) }
  end
end
