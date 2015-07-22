require 'test_helper'

class Dashboard::Company::ProductsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @company = FactoryGirl.create(:company, creator: @user)
    @product_type = FactoryGirl.create(:product_type)
    @shipping_category = FactoryGirl.create(:shipping_category)
    @shipping_category.company_id = @company.id
    @shipping_category.save!
    @shipping_method = FactoryGirl.create(:shipping_method, shipping_category_param: @shipping_category)
    10.times { FactoryGirl.create(:category) }
    @category_ids = Category.all.map(&:id)
    @countries = Spree::Country.last(10)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'controller tests' do
    setup do
      @product = FactoryGirl.create(:product, product_type: @product_type)
      @product.company = @company
      @product.user = @user
      @product.save!
    end

    should 'create new product' do
      assert_difference 'Spree::Product.count' do
        post :create, {
          product_type_id: @product.product_type.id,
          product_form: product_form_attributes
        }
      end
      assert_equal Spree::Product.last.categories.map(&:id), @category_ids
    end

    should 'update product' do
      categories = Category.last(2)
      put :update, {
        product_form: {name: 'Changed name', category_ids: [categories.map(&:id).join(',')]},
        id: @product.slug,
        product_type_id: @product.product_type.id
      }
      @product.reload
      assert_equal 'Changed name', @product.name
      assert_equal categories.map(&:id).sort, @product.category_ids.sort
    end

    should 'create mirror copies of system shipping categories' do
      initial_count = Spree::ShippingCategory.where(user_id: @user.id, is_system_profile: false).length
      get :new
      after_count = Spree::ShippingCategory.where(user_id: @user.id, is_system_profile: false).length
      assert_equal initial_count, after_count

      @shipping_category.update_attributes(is_system_profile: true, is_system_category_enabled: true)

      initial_count = Spree::ShippingCategory.where(user_id: @user.id, is_system_profile: false).length
      get :new
      after_count = Spree::ShippingCategory.where(user_id: @user.id, is_system_profile: false).length
      after_shipping_category = Spree::ShippingCategory.order('id DESC').where(user_id: @user.id, is_system_profile: false).first
      assert_equal initial_count + 1, after_count

      assert_not_equal @shipping_category.id, after_shipping_category.id
      assert_equal @shipping_category.shipping_methods.length, after_shipping_category.shipping_methods.length
      assert_equal @shipping_category.shipping_methods.first.zones.length, after_shipping_category.shipping_methods.first.zones.length
      assert_equal @shipping_category.shipping_methods.first.zones.first.members.length, after_shipping_category.shipping_methods.first.zones.first.members.length
    end
  end

  context 'import' do
    setup do
      @data_upload = FactoryGirl.create(:data_upload,
        importable: @product_type,
        csv_file: File.open(Rails.root.join('test', 'assets', 'data_importer', 'products', 'quantity_test.csv')),
        target: @company,
        uploader: @user
      )
    end

    should 'have the right quantity after import and edit via dashboard' do
      assert_difference ['Spree::Product.count', 'Spree::StockItem.count', 'Spree::StockMovement.count'] do
        DataUploadProductHostImportJob.perform(@data_upload.id)
      end

      product = Spree::Product.first
      assert_equal 1, product.stock_items.count
      assert_equal 9, product.stock_items.first.stock_movements.sum(:quantity)
      assert_equal 9, product.total_on_hand

      new_quantity = 10
      assert_no_difference 'Spree::StockItem.count' do
        put :update, { product_type_id: product.product_type.id, id: product.slug, product_form: {quantity: new_quantity, price: 10 }}
      end

      assert_equal 1, product.stock_items.count
      assert_equal new_quantity, product.stock_items.first.stock_movements.sum(:quantity)
      assert_equal new_quantity, product.total_on_hand
    end

    should 'have the right quantity after creation via dashboard and edit via bulk upload' do

      assert_difference ['Spree::Product.count', 'Spree::StockItem.count'] do
        post :create, {
          product_type_id: @product_type.id,
          product_form: {
            name: "1-PC",
            description: "TEMPERATURE CONTROLLER, FOR CRCTA SLAVE",
            price: "10",
            quantity: "10",
            shipping_category_id: @shipping_category.id
          }
        }
      end

      product = Spree::Product.first

      product.update_column :external_id, 'IN0001'

      assert_equal 10, product.total_on_hand
      assert_equal 10, product.stock_items.first.stock_movements.sum(:quantity)

      assert_no_difference ['Spree::Product.count', 'Spree::StockItem.count'] do
        assert_difference 'Spree::StockMovement.count' do
          DataUploadProductHostImportJob.perform(@data_upload.id)
        end
      end

      assert_equal 9, product.total_on_hand
      assert_equal 9, product.stock_items.first.stock_movements.sum(:quantity)
      assert_equal -1, product.stock_items.first.stock_movements.order(:id).last.quantity
    end

    should 'have the right quantity after creation and update via bulk upload' do
      assert_difference ['Spree::Product.count', 'Spree::StockItem.count', 'Spree::StockMovement.count'] do
        DataUploadProductHostImportJob.perform(@data_upload.id)
      end

      product = Spree::Product.first
      assert_equal 1, product.stock_items.count
      assert_equal 9, product.stock_items.first.stock_movements.sum(:quantity)
      assert_equal 9, product.total_on_hand

      data_upload2 = FactoryGirl.create(:data_upload,
        importable: @product_type,
        csv_file: File.open(Rails.root.join('test', 'assets', 'data_importer', 'products', 'quantity_test2.csv')),
        target: @company,
        uploader: @user
      )

      assert_no_difference ['Spree::Product.count', 'Spree::StockItem.count'] do
        assert_difference 'Spree::StockMovement.count' do
          DataUploadProductHostImportJob.perform(data_upload2.id)
        end
      end

      assert_equal 1,  product.stock_items.count
      assert_equal 11, product.stock_items.first.stock_movements.sum(:quantity)
      assert_equal 11, product.total_on_hand
      assert_equal 2,  product.stock_items.first.stock_movements.order(:id).last.quantity
    end
  end

  def product_form_attributes
    {
      name: "Test Product",
      description: "Test description",
      price: "100",
      category_ids: [@category_ids.join(",")],
      quantity: "10",
      shipping_category_id: @shipping_category.id
    }
  end
end
