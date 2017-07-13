require "test_helper"

class AccessorsTest < ActionDispatch::IntegrationTest

  setup do
    @sample_model_type = FactoryGirl.create(:sample_model_type)
  end

  context 'attribute with sensitive name and default value' do

    setup do
      @custom_attribute = FactoryGirl.create(:custom_attribute, name: 'destroy', target: @sample_model_type)
    end

    context 'basic' do

      setup do
        @sample_model = FactoryGirl.create(:sample_model, sample_model_type: @sample_model_type)
      end


      should 'be nil initially without default value' do
        assert_nil @sample_model.properties.destroy
      end

      should 'be able to store new value' do
        @sample_model.properties.destroy = 10
        @sample_model.save!
        assert_equal 10, @sample_model.reload.properties.destroy
      end

      should 'not persist changes automatically' do
        @sample_model.properties.destroy = 8
        @sample_model.reload
        assert_nil @sample_model.reload.properties.destroy
      end

      should 'work for different way of setting attribute' do
        @sample_model.properties['destroy'] = '8'
        @sample_model.save!
        assert_equal 8, @sample_model.reload.properties.destroy
      end

    end
    context 'bulk attribute' do

      setup do
        @custom_attribute.update_attribute(:default_value, 6)
        @custom_attribute2 = FactoryGirl.create(:custom_attribute, name: 'attr', target: @sample_model_type, default_value: 3)
      end

      should 'set one attribute and use default value for other' do
        @sample_model = FactoryGirl.create(:sample_model, sample_model_type: @sample_model_type, properties: { attr: 5 })
        assert_equal 5, @sample_model.properties.attr
        assert_equal 6, @sample_model.properties.destroy
      end

      should 'properly persist new hash if provided and do add defaults for new one' do
        @sample_model = FactoryGirl.create(:sample_model, sample_model_type: @sample_model_type)
        assert_equal 3, @sample_model.properties.attr
        assert_equal 6, @sample_model.properties.destroy
        @sample_model.update_attribute(:properties, { 'attr' => '50' })
        @sample_model.reload
        assert_equal 50, @sample_model.properties.attr
        assert_equal 6, @sample_model.properties.destroy
        @custom_attribute3 = FactoryGirl.create(:custom_attribute, name: 'another_attr', target: @sample_model_type, default_value: 20)

        clear_all_cache!
        @sample_model = SampleModel.find(@sample_model.id)
        assert_equal 50, @sample_model.properties.attr
        assert_equal 6, @sample_model.properties.destroy
        assert_equal 20, @sample_model.properties.another_attr
        assert_equal({'attr' => '50', 'destroy' => '6', 'another_attr' => '20'}, @sample_model.properties.instance_variable_get('@hash'))
        @custom_attribute3.destroy
        clear_all_cache!
        @sample_model = SampleModel.find(@sample_model.id)
        assert_equal 50, @sample_model.properties.attr
        assert_equal 6, @sample_model.properties.destroy
        assert_equal({'attr' => '50', 'destroy' => '6'}, @sample_model.properties.instance_variable_get('@hash'))
        refute @sample_model.properties.respond_to?(:another_attr)
      end

      should 'properly set default if setting properties is delayed' do
        @sample_model = FactoryGirl.build(:sample_model, sample_model_type: @sample_model_type)
        assert_equal 3, @sample_model.properties.attr
        assert_equal 6, @sample_model.properties.destroy
        @sample_model.properties = { 'attr' => '50' }
        assert_equal 50, @sample_model.properties.attr
        assert_equal 6, @sample_model.properties.destroy
      end

      should 'both attributes should be persisted' do
        @sample_model = FactoryGirl.create(:sample_model, sample_model_type: @sample_model_type, properties: { attr: 5, 'destroy' => '9' })
        assert_equal 5, @sample_model.properties.attr
        assert_equal 9, @sample_model.properties.destroy
        @sample_model.reload
        assert_equal 5, @sample_model.properties.attr
        assert_equal 9, @sample_model.properties.destroy

      end

    end

    context 'default value' do

      setup do
        @custom_attribute.update_attribute(:default_value, 5)
        @sample_model = FactoryGirl.create(:sample_model, sample_model_type: @sample_model_type)
      end

      should 'allow to set nil as value for not persisted object' do
        @sample_model = FactoryGirl.build(:sample_model, sample_model_type: @sample_model_type)
        @sample_model.properties = { destroy: nil }
        assert_nil @sample_model.properties.destroy
        @sample_model.save!
        assert_nil @sample_model.reload.properties.destroy
      end

      should 'be able to overwrite default with other value' do
        @sample_model.properties.destroy = 10
        @sample_model.save!
        assert_equal 10, @sample_model.reload.properties.destroy
      end

      should 'be able to overwrite default with nil' do
        @sample_model.properties.destroy = nil
        @sample_model.save!
        assert_nil @sample_model.reload.properties.destroy
      end

      should 'fallback to default value if record not saved' do
        @sample_model.properties.destroy = 10
        assert_equal 5, @sample_model.reload.properties.destroy
      end
    end

  end

  context 'array values' do

    setup do
      @custom_attribute = FactoryGirl.create(:custom_attribute_array, target: @sample_model_type)
      @sample_model = @sample_model_type.sample_models.build
    end

    should 'be able to submit strings that will be parsed as array, then save and reload array' do
      @sample_model.properties.array = 'One, Two    ,    Three,Four'
      assert_equal ['One', 'Two', 'Three', 'Four'], @sample_model.properties.array
      @sample_model.save!
      @sample_model.reload
      assert_equal ['One', 'Two', 'Three', 'Four'], @sample_model.properties.array
      @sample_model.save!
      @sample_model.reload
      assert_equal ['One', 'Two', 'Three', 'Four'], @sample_model.properties.array
    end

    should 'be able to assign array as array' do
      @sample_model.properties.array = ['One', 'Two', 'Three', 'Four']
      assert_equal ['One', 'Two', 'Three', 'Four'], @sample_model.properties.array
      @sample_model.save!
      @sample_model.reload
      assert_equal ['One', 'Two', 'Three', 'Four'], @sample_model.properties.array
    end

    should 'return empty array if nil' do
      @sample_model.properties.array = nil
      assert_equal [], @sample_model.properties.array
    end

  end

end
