require 'test_helper'
require 'rails/performance_test_help'

class TransactableTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
   self.profile_options = { :runs => 5, :metrics => [:process_time, :memory],
                            :output => 'tmp/benchmark', :formats => [:call_tree] }

  setup do
    @instance = FactoryGirl.create(:instance)
    PlatformContext.current = PlatformContext.new(@instance)
    @transactable_type = FactoryGirl.create(:transactable_type_listing)
  end

  context 'initializing' do

    setup do
      15.times do
        FactoryGirl.create(:transactable)
      end
    end

    should 'initialize 15 transactables' do
      @transactables = Transactable.all
      assert_equal 15, @transactables.size

    end

  end

end
