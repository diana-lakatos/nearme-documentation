require 'mocha/api'

Class.send(:include, Mocha::ClassMethods)
World(Mocha::API)

Before do
  mocha_setup
end

After do
  begin
    mocha_verify
  ensure
    mocha_teardown
  end
end
