require 'test_helper'

class RelNoFollowAdderTest < ActiveSupport::TestCase
  setup do
    @rel_no_follow_adder = RelNoFollowAdder.new(skip_domains: ['allowed.domain.com'])
  end

  context 'single link' do
    should 'have no follow if its domain is not known' do
      assert_equal '<div><a href="http://example.com" rel="nofollow">Should have no follow</a></div>', @rel_no_follow_adder.modify('<div><a href="http://example.com">Should have no follow</a></div>')
    end

    should 'not have double follow if it has been already set' do
      assert_equal '<div><a href="http://example.com" rel="nofollow">Should have no follow</a></div>', @rel_no_follow_adder.modify('<div><a href="http://example.com" rel="nofollow">Should have no follow</a></div>')
    end

    should 'not lose anything what was in rel attribute before' do
      assert_equal '<div><a href="http://example.com" rel="tooltip nofollow">Should have no follow</a></div>', @rel_no_follow_adder.modify('<div><a href="http://example.com" rel="tooltip">Should have no follow</a></div>')
    end

    should 'not have nofollow if href contains http://<known domain>' do
      assert_equal '<div><a href="http://allowed.domain.com">Without nofollow</a></div>', @rel_no_follow_adder.modify('<div><a href="http://allowed.domain.com">Without nofollow</a></div>')
    end

    should 'not have nofollow if href contains https://www.<known domain>' do
      assert_equal '<div><a href="https://www.allowed.domain.com">Without nofollow</a></div>', @rel_no_follow_adder.modify('<div><a href="https://www.allowed.domain.com">Without nofollow</a></div>')
    end

    should 'not add nofollow to mailto' do
      assert_equal '<div><a href="mailto:john@example.com">Without nofollow</a></div>', @rel_no_follow_adder.modify('<div><a href="mailto:john@example.com">Without nofollow</a></div>')
    end

    should 'not add nofollow to relative link' do
      assert_equal '<div><a href="/some/path">Without nofollow</a></div>', @rel_no_follow_adder.modify('<div><a href="/some/path">Without nofollow</a></div>')
    end
  end

  context 'multiple links' do
    should 'distinguish between links that should have nofollow and not' do
      expected_message = "<div>\n#{link_after_modification}#{link_after_modification}<div>#{link_after_modification}</div>\n</div><div>#{link_after_modification}</div><p>#{link_without_no_follow} was cool</p>"
      input_message = "<div>#{link_before_modification}#{link_before_modification}<div>#{link_before_modification}</div></div><div>#{link_before_modification}</div><p>#{link_without_no_follow} was cool</p>"
      assert_equal(expected_message, @rel_no_follow_adder.modify(input_message))
    end
  end

  private

  def link_before_modification
    '<a href="http://www.domain.com" rel="something">With no follow</a>'
  end

  def link_after_modification
    '<a href="http://www.domain.com" rel="something nofollow">With no follow</a>'
  end

  def link_without_no_follow
    '<a href="http://allowed.domain.com">Without nofollow</a>'
  end
end
