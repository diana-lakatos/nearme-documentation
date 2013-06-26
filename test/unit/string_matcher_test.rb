require 'test_helper'

class StringMatcherTest < ActiveSupport::TestCase

  context 'matching' do
    should 'correctly match pairs' do
      @string_matcher = StringMatcher.new(['abc', 'xyz', '123'], ['23x', 'abcxy', 'totaly wrong'])
      assert_equal ({ 'abc' => ['abcxy'], 'xyz' => ['abcxy'], '123' => ['23x']}), @string_matcher.create_pairs
    end

    should 'correctly match listing names to file names' do
      @string_matcher = StringMatcher.new(
        ['903 - Small Conference Room', '904 - Middle Conference Room', '905 - Large Conference Room', '912 Day Office'],
        ['BH1-Building.jpg', 'BH1-Conf1.jpg', 'BH1-Conf2.jpg', 'BH1-Lobby.jpg', 'BH1-Office2.jpg']
      )
      assert_equal ({ 
        '903 - Small Conference Room' => ['BH1-Conf1.jpg', 'BH1-Conf2.jpg'], 
        '904 - Middle Conference Room' => ['BH1-Conf1.jpg', 'BH1-Conf2.jpg'],
        '905 - Large Conference Room' => ['BH1-Conf1.jpg', 'BH1-Conf2.jpg'],
        '912 Day Office' => ['BH1-Office2.jpg']
      }), @string_matcher.create_pairs
    end
  end
end
