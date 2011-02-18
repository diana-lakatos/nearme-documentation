if Rails.env.production?
  DesksnearMe::Application.config.middleware.use ExceptionNotifier,
      :email_prefix => "[Bug] ",
      :sender_address => %{"notifier" <bugs@desksnear.me>},
      :exception_recipients => %w{bugs@desksnear.me}
end
