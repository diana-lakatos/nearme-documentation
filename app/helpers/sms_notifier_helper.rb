module SmsNotifierHelper
  def shorten_url(url)
    Googl.shorten(url).short_url
  end

  def main_app
    Rails.application.routes.url_helpers
  end
end

