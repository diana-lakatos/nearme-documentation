require 'test_helper'

class FakeDataSeederTest < ActiveSupport::TestCase

  setup do
    @seeder = Utils::FakeDataSeeder.new
  end

  context "#go!" do
    context "wrong ENV" do
      should "raise proper expception" do
        Rails.env.stubs(:production?).returns(true)
        assert_raises(Utils::FakeDataSeeder::WrongEnvironmentError) { @seeder.go! }
      end
    end

    context "not empty database" do
      should "raise proper expception" do
        User.stubs(:any?).returns(true)
        assert_raises(Utils::FakeDataSeeder::NotEmptyDatabaseError) { @seeder.go! }
      end
    end

    context "proper env and empty database" do
      should "load data" do
        [Location, User, Company, Instance].each { |klazz| klazz.stubs(:any?).returns(false) }
        @seeder.expects(:load_data!)
        @seeder.go!
      end
    end
  end
end
