unless ENV['RAILS_ENV'] == 'test'
  Utils::FakeDataSeeder.new.go!
end
