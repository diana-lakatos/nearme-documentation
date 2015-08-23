require 'test_helper'

class RatingSystemTest < ActiveSupport::TestCase
  should belong_to(:instance)
  should have_many(:rating_hints).dependent(:destroy)
  should have_many(:rating_questions).dependent(:destroy)

  should accept_nested_attributes_for(:rating_questions).allow_destroy(true)
  should accept_nested_attributes_for(:rating_hints)

  context "instance methods" do
    context "set subject correctly" do
      setup do
        @instance = PlatformContext.current.instance
        @rating_system = FactoryGirl.build(:rating_system)
        @transactable_type = FactoryGirl.create(:transactable_type_buy_sell)
        @rating_system.transactable_type_id = @transactable_type.id
      end

      should "for 'transactable' subject" do
        @rating_system.subject = RatingConstants::TRANSACTABLE
        assert_equal RatingConstants::TRANSACTABLE, @rating_system.subject
      end

      should "for 'guest' subject" do
        @rating_system.subject = RatingConstants::GUEST
        assert_equal @transactable_type.lessee, @rating_system.subject

        @rating_system.transactable_type = nil
        assert_equal @instance.lessee, @rating_system.subject
      end

      should "for 'host' subject" do
        @rating_system.subject = RatingConstants::HOST
        assert_equal @transactable_type.lessor, @rating_system.subject

        @rating_system.transactable_type = nil
        assert_equal @instance.lessor, @rating_system.subject
      end

      should "for any other subject" do
        @rating_system.subject = "whatever"
        assert_equal "whatever", @rating_system.subject
      end
    end
  end
end
