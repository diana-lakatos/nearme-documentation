module SalesforceLead
  FORM_POST_URL = "https://www.salesforce.com/servlet/servlet.WebToLead?encoding=UTF-8"

  def create_salesforce_lead
    begin
      uri = URI.parse(FORM_POST_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)

      request.set_form_data({"oid" => "00DG0000000CGnm",
                             "first_name"      => name.split(' ').first,
                             "last_name"       => name.split(' ').from(1).join(' '),
                             "email"           => attributes['email'],
                             "company"         => attributes['company'],
                             "phone"           => attributes['phone'],
                             "00NG000000DfhsK" => attributes['marketplace_type'],
                             "lead_source"     => attributes['lead_source'],
                             "00NG000000DgV2W" => attributes['location'],
                             "00NG000000DgV2l" => attributes['previous_research'],
                             "00NG000000Ddp2w" => attributes['comments'],
                             "00NG000000DduGh" => subscribed? ? '1' : '',
                             "lead_source"     => "Web"})

      response = http.request(request) if Rails.env.production?
    rescue => exception
      Raygun.track_exception(exception)
    end
  end
end
