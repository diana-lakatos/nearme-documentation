require 'test_helper'

class ProductDecoratorTest < ActionView::TestCase
   context 'new product creation' do

    setup do
      @product = create(:base_product)
    end

    should 'have the same company assigned to product and master variant' do
      assert @product.company.class, Company
      assert @product.company, @product.master.company
    end
  end
end
