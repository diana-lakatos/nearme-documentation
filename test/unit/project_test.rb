require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  setup do
    @project = create(:project)
  end

  context "included modules" do
    %w(
      PlatformContext::DefaultScoper
      PlatformContext::ForeignKeysAssigner
    ).each do |_module|
      should "include #{_module}" do
        assert ActivityFeedEvent.included_modules.include?(_module.constantize)
      end
    end
  end

  context "associations" do
    should have_many(:project_collaborators)
    should have_many(:project_topics)
    should have_many(:topics)
    should have_many(:data_source_contents)
    should have_many(:user_messages)
    should have_many(:wish_list_items)
    should have_many(:photos)
    should have_many(:links)

    should belong_to(:transactable_type)
    should belong_to(:creator)
  end

  context "scopes" do
    should ".by_topic" do
      @topic1 = create(:topic)
      @topic2 = create(:topic)
      @project.topics << [@topic1, @topic2]
      @another_project = create(:project)
      assert_includes Project.by_topic([@topic1.id, @topic2.id]), @project
    end
  end

  context "save assciated" do
    should "update links when project is saved" do
      @project = FactoryGirl.create(:project)
      assert_equal 1, @project.links.count
      @link = @project.links.first

      links_attributes = { "0" => { "text" => "Changed", id: @link.id }}
      @project.assign_attributes({"links_attributes" => links_attributes})
      @project.save
      @project.reload
      assert_equal "Changed", @project.links.first.text

      links_attributes = { "0" => { "text" => "Changed", id: @link.id, _destroy: true }}
      @project.assign_attributes({"links_attributes" => links_attributes})
      @project.save
      @project.reload
      assert_equal nil, @project.links.first

    end
  end
end
