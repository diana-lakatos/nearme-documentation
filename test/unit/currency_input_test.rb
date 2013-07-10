require 'test_helper'

class CurrencyInputTest < ActiveSupport::TestCase

  should "put all the currencies into the All group" do
    assert input.grouped_collection[1].name == 'All'
    assert input.grouped_collection[1].currencies.size == DesksnearMe::Application.config.supported_currencies.size
  end

  should "group the currencies by priority" do
    assert input.grouped_collection[0].name == 'Common'
  end

  context "The Common Group" do

    should "include USD" do
      assert input.grouped_collection[0].include?("USD - United States Dollar")
    end

    should "include EUR" do
      assert input.grouped_collection[0].include?("EUR - European Union Euro")
    end

    should "include NZD" do
      assert input.grouped_collection[0].include?("NZD - New Zealand Dollar")
    end

    should "include AUD" do
      assert input.grouped_collection[0].include?("AUD - Australian Dollar")
    end

    should "include GBP" do
      assert input.grouped_collection[0].include?("GBP - United Kingdom Sterling Pound")
    end
  end
  def input
    @input ||= CurrencyInput.new(nil, nil, nil, nil)
  end

end
