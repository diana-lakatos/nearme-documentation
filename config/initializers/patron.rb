class Patron::Session
  def initialize
    @headers = {}
    @timeout = 30
    @connect_timeout = 3
    @max_redirects = 5
    @auth_type = :basic
  end
end
