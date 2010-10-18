DesksnearMe::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => "[Bug] ",
    :sender_address => %{"notifier" <bugs@desksnearme.com>},
    :exception_recipients => %w{bugs@desksnearme.com}
