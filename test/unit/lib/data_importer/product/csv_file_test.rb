require 'test_helper'

class DataImporter::Product::CsvFileTest < ActiveSupport::TestCase

  context '#process_next_row' do
    setup do
      @product_csv = DataImporter::Product::CsvFile.new(create(:products_data_upload))
    end

    should 'return models hashes in params hash' do
      params = @product_csv.process_next_row

      [:user, :company, :'spree/variant', :'spree/image'].each do |model|
        assert_includes(params, :user)
        assert_kind_of(Hash, params[model])
        refute_empty(params[model])
      end
    end

    should 'return right amount of hashes' do
      count = 0
      while @product_csv.process_next_row
        count += 1
      end
      assert_equal 2, count
    end

    should 'return nil on consequent calls' do
      @product_csv.process_next_row
      @product_csv.process_next_row
      assert_nil @product_csv.process_next_row
    end

    should 'return proper data' do
      params = @product_csv.process_next_row
      assert_equal 'user 1', params[:user][:name]
      assert_equal 'company 1', params[:company][:name]
      assert_equal 'ship', params[:'spree/shipping_category'][:name]
      assert_equal 'product 1', params[:'spree/product'][:name]
      assert_equal 'in', params[:'spree/variant'][:width_unit]
      assert_equal 'http://www.example.com/image1.jpg', params[:'spree/image'][:image_original_url]
    end
  end

  context 'Host subclass' do
    setup do
      @data_upload = create(:products_data_upload_from_dashboard)
      @product_csv = DataImporter::Product::Host::CsvFile.new(@data_upload)
    end

    context '#attributes_for' do
      should 'return creators data for user and company' do
        params = @product_csv.process_next_row
        assert_equal @data_upload.uploader.name, params[:user][:name]
        assert_equal @data_upload.uploader.companies.first.name, params[:company][:name]
      end
    end
  end

end
