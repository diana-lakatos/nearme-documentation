require 'test_helper'

class Reservation::ContiguousBlockFinderTest < ActiveSupport::TestCase
  def setup
    @reservation = Reservation.new

    @listing = stub()
    @listing.stubs(:open_on?).returns(true)
    @listing.stubs(:availability_for).returns(10)
    @reservation.stubs(:listing).returns(@listing)
    
    @contiguous_block_finder = Reservation::ContiguousBlockFinder.new(@reservation)
  end

  context '#contiguous_blocks' do
    should "be correct for a single date" do
      dates = date_groups_of(1, 1)
      seed_reservation_dates(dates)

      assert_equal dates, @contiguous_block_finder.contiguous_blocks
    end

    should "be correct for a set of single dates" do
      dates = date_groups_of(1, 3)
      seed_reservation_dates(dates)

      assert_equal dates, @contiguous_block_finder.contiguous_blocks
    end

    should "be correct for multiple dates" do
      dates = date_groups_of(3, 1)
      seed_reservation_dates(dates)

      assert_equal dates, @contiguous_block_finder.contiguous_blocks
    end

    should "be correct for a set of multiple dates" do
      dates = date_groups_of(3, 3)
      seed_reservation_dates(dates)

      assert_equal dates, @contiguous_block_finder.contiguous_blocks
    end

    context "semantics with availability" do
      setup do
        @reservation.quantity = 2

        # We set up a set of dates with gaps that are deemed "contiguous" by our 
        # custom definition.
        @dates = [Date.today, Date.today + 2.days, Date.today + 4.days, Date.today + 5.days, Date.today + 8.days]
        @dates.each do |date|
          @listing.stubs(:availability_for).with(date).returns(2)
          @listing.stubs(:open_on?).with(date).returns(true)
        end

        @closed = [Date.today + 1.day]
        @closed.each do |date|
          @listing.stubs(:open_on?).with(date).returns(false)
        end

        @unavailable = [Date.today + 3.days]
        @unavailable.each do |date|
          @listing.stubs(:open_on?).with(date).returns(true)
          @listing.stubs(:availability_for).with(date).returns(1)
        end

        @listing.stubs(:open_on?).with(Date.today + 5.days).returns(false)
     
        seed_reservation_dates(@dates)
      end

      should "take into account listing availability" do
        blocks = @contiguous_block_finder.contiguous_blocks
        assert_equal @dates.slice(0, 4), blocks[0], blocks.inspect
        assert_equal @dates.slice(4, 1), blocks[1], blocks.inspect
      end

      should "be able to ignore listing availability" do
        @contiguous_block_finder = Reservation::ContiguousBlockFinder.new(@reservation, true)
        blocks = @contiguous_block_finder.contiguous_blocks

        assert_equal @dates.slice(0, 1), blocks[0], blocks.inspect
        assert_equal @dates.slice(1, 1), blocks[1], blocks.inspect
        assert_equal @dates.slice(2, 2), blocks[2], blocks.inspect
        assert_equal @dates.slice(4, 1), blocks[3], blocks.inspect
      end
    end
  end

  private

  # Return dates in groups to use for seeding the tests
  def date_groups_of(count = 1, quantity = 3)
    quantity.times.map do |i|
      count.times.map do |c|
        Date.today.advance(:months => i*count, :days => c)
      end
    end
  end

  def seed_reservation_dates(dates, reservation = @reservation)
    dates.flatten.uniq.each do |date|
      reservation.periods.build(:date => date)
    end
  end

end

