class LinkedinImageRetrieverService
  def initialize(oauth_token)
    @oauth_token = oauth_token
  end

  def retrieve_original_image
    api_url = "https://api.linkedin.com/v1/people/~/picture-urls::(original)?oauth2_access_token=#{@oauth_token}"

    xml_data = Net::HTTP.get_response(URI.parse(api_url)).body
    doc = REXML::Document.new(xml_data)
    elements = doc.elements.each('*/picture-url/text()') { |element| element }

    # Will be nil or "" if array is empty
    elements.first.to_s
  rescue StandardError
    nil
  end
end
