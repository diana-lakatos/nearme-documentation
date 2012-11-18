require 'minitest/autorun'
require 'mocha/setup'
unless defined? Listing
  class Listing
    module Search
      class Params
      end
    end
  end
end
