require 'minitest/autorun'
require 'minitest/spec'

# This is needed to avoid errors with assertions in cucumber tests
# otherwise 'assert something_to_true' will raise an error
# "undefined method `+' for nil:NilClass (NoMethodError)"
class MinitestWorld
  extend Minitest::Assertions
  attr_accessor :assertions

  def initialize
    self.assertions = 0
  end
end
World(MultiTest::MinitestWorld)
