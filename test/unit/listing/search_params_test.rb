require "test_helper"
class Listing::SearchParamsTest < ActiveSupport::TestCase
  context "#parsed_params" do
    context "#price_max" do
      def setup
        @params = {
          price: { min: 0, max: 100}
        }
      end

      should "be 10 when searching for a max price of 10" do
        @params[:price][:max] = 10
        search = Listing::SearchParams.new(@params)
        assert_equal 10, search.price_max
      end

      should "be 9999 when searching for MAX_SEARCHABLE_PRICE" do
        @params[:price][:max] = Listing::SearchParams::MAX_SEARCHABLE_PRICE
        search = Listing::SearchParams.new(@params)
        assert_equal 9999, search.price_max
      end
    end
  end
end
