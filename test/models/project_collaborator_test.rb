require 'test_helper'

class ProjectCollaboratorTest < ActiveSupport::TestCase
  should belong_to(:user)
  should belong_to(:project)

  context 'state machine' do

    should 'apply correct states' do
      @project_collaborator = FactoryGirl.create(:project_collaborator)

      assert @project_collaborator.pending?

      @project_collaborator.update_attributes({approved: 'true'})
      assert @project_collaborator.approved_by_owner?
      refute @project_collaborator.approved_by_user?
      @project_collaborator.approve_by_user!
      assert @project_collaborator.approved_by_user?
      assert @project_collaborator.approved?
      refute @project_collaborator.pending?

      assert_equal [@project_collaborator], @project_collaborator.project.project_collaborators.approved
    end
  end
end
