require 'test_helper'

class TransactableCollaboratorTest < ActiveSupport::TestCase
  should belong_to(:user)
  should belong_to(:transactable)

  context 'state machine' do
    should 'apply correct states' do
      @transactable_collaborator = FactoryGirl.create(:transactable_collaborator)

      assert @transactable_collaborator.pending?

      @transactable_collaborator.update_attributes(approved: 'true')
      assert @transactable_collaborator.approved_by_owner?
      refute @transactable_collaborator.approved_by_user?
      @transactable_collaborator.approve_by_user!
      assert @transactable_collaborator.approved_by_user?
      assert @transactable_collaborator.approved?
      refute @transactable_collaborator.pending?

      assert_equal [@transactable_collaborator], @transactable_collaborator.transactable.transactable_collaborators.approved
    end
  end
end
