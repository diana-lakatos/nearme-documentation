class Payment::Gateway::Response::Stripe::Version
  STRIPE_VERSION_FORMAT = "%Y-%m-%d"

  def initialize(api_version)
    @api_version = api_version
  end

  def >= (version)
    parse_date_version(@api_version) > parse_date_version(version)
  end

  def < (version)
    parse_date_version(@api_version) < parse_date_version(version)
  end

  def parse_date_version(string_date)
     Date.strptime(string_date, STRIPE_VERSION_FORMAT)
  end
end
