require 'test_helper'

class Elastic::QueryBuilderTest < ActiveSupport::TestCase

  setup do
    @qbuilder = Elastic::QueryBuilder.new({}, [], TransactableType.first)
  end

  context "filters" do
    context "initial_product_filters" do
      should "should use _terms_ query" do
        terms_filter = @qbuilder.initial_product_filters.last
        assert_equal(terms_filter.keys.first, :term)
      end
    end

    context "initial_service_filters" do
      should "should use _terms_ query" do
        terms_filter = @qbuilder.initial_service_filters.last
        assert_equal(terms_filter.keys.first, :term)
      end
    end
  end
end
