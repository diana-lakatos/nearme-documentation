require 'test_helper'

class DataImporter::Tracker::ProgressTrackerTest < ActiveSupport::TestCase
  setup do
    @data_upload = stub
    @progress_tracker = DataImporter::Tracker::ProgressTracker.new(@data_upload, 1000)
  end

  context 'processing' do
    should 'track processing of location' do
      DataImporter::Tracker::ProgressTracker::Updater.any_instance.expects(:update).times(3)
      @progress_tracker.object_created(Location.new)
      @progress_tracker.object_valid(Location.new)
      @progress_tracker.object_not_valid(Location.new)
    end

    should 'track processing of transactable' do
      DataImporter::Tracker::ProgressTracker::Updater.any_instance.expects(:update).times(3)
      @progress_tracker.object_created(Transactable.new)
      @progress_tracker.object_valid(Transactable.new)
      @progress_tracker.object_not_valid(Transactable.new)
    end

    should 'track processing of photo' do
      DataImporter::Tracker::ProgressTracker::Updater.any_instance.expects(:update).times(3)
      @progress_tracker.object_created(Photo.new)
      @progress_tracker.object_valid(Photo.new)
      @progress_tracker.object_not_valid(Photo.new)
    end

    should 'not track processing of user' do
      DataImporter::Tracker::ProgressTracker::Updater.any_instance.expects(:update).never
      @progress_tracker.object_created(User.new)
      @progress_tracker.object_valid(User.new)
      @progress_tracker.object_not_valid(User.new)
    end

    should 'not track processing of company' do
      DataImporter::Tracker::ProgressTracker::Updater.any_instance.expects(:update).never
      @progress_tracker.object_created(Company.new)
      @progress_tracker.object_valid(Company.new)
      @progress_tracker.object_not_valid(Company.new)
    end
  end

  context 'updating!' do
    should 'ensures that no matter how many objects, we will always update status max 100 times' do
      100.times do |i|
        @data_upload.expects(:update_column).never
        9.times do
          @progress_tracker.object_created(Location.new)
        end
        # i starts from 0, first progress update is with 1, last is 100, hence +1
        @data_upload.expects(:update_column).once.with(:progress_percentage, i + 1)
        @progress_tracker.object_created(Location.new)
      end
    end

    should 'ignore processing unrelated entities' do
      @data_upload.expects(:update_column).never
      9.times do
        @progress_tracker.object_created(Location.new)
      end
      @progress_tracker.object_created(User.new)
    end
  end
end
