unless ENV['RAILS_ENV'] == 'test'
  Utils::FakeDataSeeder.new.go!
  PrepareEmail.import_legacy
end
