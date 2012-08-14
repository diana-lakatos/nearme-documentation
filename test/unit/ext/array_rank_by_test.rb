require 'test_helper'

class ArrayRankByTest < ActiveSupport::TestCase

  class Team < Struct.new(:score); end

  context "when ranking an array of objects" do

    setup do
      scores            = [10, 14, 18, 22, 33, 36]
      scores_with_evens = [10, 14, 14, 14, 18, 22, 22, 33, 36]

      @teams            = scores.map { |s| Team.new(s) }
      @teams_with_evens = scores_with_evens.map { |s| Team.new(s) }
    end

    should "return an array ranked by score" do
      shuffled_teams = @teams.shuffle

      # this has a 1/6! chance of failing ;)
      assert_not_equal shuffled_teams, @teams

      ranked_teams = shuffled_teams.rank_by(&:score)

      assert_equal @teams, ranked_teams.flatten
    end

    should "return a nested array if two objects have the same score" do
      shuffled_teams = @teams_with_evens.shuffle

      # this has a 1/9! chance of failing ;)
      assert_not_equal shuffled_teams, @teams_with_evens

      ranked_teams = shuffled_teams.rank_by(&:score)

      assert_equal [[10], [14, 14, 14], [18], [22, 22], [33], [36]], ranked_teams.map { |ts| ts.map(&:score) }
    end

  end


end
