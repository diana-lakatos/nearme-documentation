unless ENV['RAILS_ENV'] == 'test'
  require Rails.root.join('test', 'helpers', 'prepare_email')
  Utils::FakeDataSeeder.new.go!
  PrepareEmail.import_legacy
end
