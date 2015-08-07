require 'test_helper'

class TransactableTypeTest < ActiveSupport::TestCase

  context 'pricing_options_long_period_names' do
    should 'return only active long term names' do
      assert_equal(%w(weekly monthly), FactoryGirl.build(:transactable_type, action_hourly_booking: false, action_daily_booking: false, action_weekly_booking: true, action_monthly_booking: true).pricing_options_long_period_names)
    end
  end

  context 'pricing_validation_is_correct' do
    setup do
      @transactable_type = ServiceType.first
    end

    should 'be valid if max is greater than min' do
      @transactable_type.min_daily_price_cents = 1
      @transactable_type.max_daily_price_cents = 9
      assert @transactable_type.valid?, "expected valid, but errors were found: #{@transactable_type.errors.to_json}"
    end

    should 'not be valid if min is lower than 0' do
      @transactable_type.min_daily_price_cents = -1
      @transactable_type.max_daily_price_cents = nil
      refute @transactable_type.valid?
    end

    should 'be valid if min is 0' do
      @transactable_type.min_daily_price_cents = 0
      @transactable_type.max_daily_price_cents = nil
      assert @transactable_type.valid?
    end

    should 'be valid if max is equal to max price' do
      @transactable_type.max_daily_price_cents = ServiceType::MAX_PRICE
      assert @transactable_type.valid?
    end

    should 'not be valid if max is greater than max price' do
      @transactable_type.max_daily_price_cents = ServiceType::MAX_PRICE+1
      refute @transactable_type.valid?
    end

    should 'be valid if min and max are nil' do
      @transactable_type.min_daily_price_cents = nil
      @transactable_type.max_daily_price_cents = nil
      assert @transactable_type.valid?
    end

    should 'not be valid if min is greater than max' do
      @transactable_type.min_daily_price_cents = 10
      @transactable_type.max_daily_price_cents = 9
      refute @transactable_type.valid?
    end

    should 'be valid if daily min is greater than weekly max' do
      @transactable_type.min_daily_price_cents = 10
      @transactable_type.max_weekly_price_cents = 9
      assert @transactable_type.valid?
    end

  end

  context '#booking_choices' do
    setup do
      @transactable_type = TransactableType.first
    end

    should "include regular if hourly, daily, weekly, monthly or free action is enabled" do
      @transactable_type.action_daily_booking = true
      assert(@transactable_type.booking_choices.include?('regular'))
    end

    should "define enabled methods" do
      ServiceType::BOOKING_TYPES.each do |bt|
        assert(@transactable_type.respond_to?("#{bt}_booking_enabled?"))
      end
    end
  end

  context '#destroying translations' do

    setup do
      @transactable_type = FactoryGirl.create(:transactable_type, name: 'My custom tt')
      @select_attribute = FactoryGirl.create(:custom_attribute, target: @transactable_type, name: 'some_attr', attribute_type: 'string', valid_values: %w(red green blue), html_tag: 'select', prompt: 'my prompt')
    end

    should 'remove old translations when changing name' do
      translations = Translation.where('instance_id = ? AND (key like ? OR key like ?)', PlatformContext.current.instance.id, '%my_custom_tt%', '%my_custom_tts%')
      refute translations.empty?
      @transactable_type.update_attribute(:name, 'my new name')
      translations = Translation.where('instance_id = ? AND (key like ? OR key like ?)', PlatformContext.current.instance.id, '%my_custom_tt%', '%my_custom_tts%')
      assert translations.empty?, 'Expected old translations to be deleted'
    end

    should 'create new translations' do
      assert_no_difference 'Translation.count' do
        @transactable_type.update_attribute(:name, 'My new name')
      end
      translations = Translation.where('instance_id = ? AND (key like ? OR key like ?)', PlatformContext.current.instance.id, '%my_new_name%', '%my_new_name%')
      refute translations.empty?, 'Expected new translations to be created'
    end

    should 'not destroy random translations' do
      t1 = FactoryGirl.create(:translation, instance_id: PlatformContext.current.instance.id, key: 'random.translation_my_custom_tt_suffix')
      t2 = FactoryGirl.create(:translation, instance_id: PlatformContext.current.instance.id, key: 'random.my_custom_tt')
      t3 = FactoryGirl.create(:translation, instance_id: PlatformContext.current.instance.id, key: 'random.my_custom_tt.something')
      @transactable_type.update_attribute(:name, 'My new name')
      assert t1.reload.present?
      assert t2.reload.present?
      assert t3.reload.present?
    end

  end
end
