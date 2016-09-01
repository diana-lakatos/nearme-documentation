require 'test_helper'

class Api::V3::TransactableCollaboratorsControllerTest < ActionController::TestCase

  context '#create' do

    setup do
      @transactable = FactoryGirl.create(:transactable)
    end

    context 'creator of the listing' do

      setup do
        set_authentication_header(@transactable.creator)
        @invited_user = FactoryGirl.create(:user)
      end

      should 'invite user to collaborate' do
        assert_difference('TransactableCollaborator.count') do
          post :create, transactable_id: @transactable.id, user_id: @invited_user.id, format: :json
        end

        transactable_collaborator = @transactable.reload.transactable_collaborators.last
        assert_nil transactable_collaborator.approved_by_user_at
        assert_not_nil transactable_collaborator.approved_by_owner_at
        assert_equal @invited_user.id, transactable_collaborator.user_id
        # do not duplicate
        assert_no_difference('TransactableCollaborator.count') do
          post :create, transactable_id: @transactable.id, user_id: @invited_user.id, format: :json
        end
      end
    end

    context 'not a creator of the listing' do

      setup do
        @user_who_asks_for_permission = FactoryGirl.create(:user)
        set_authentication_header(@user_who_asks_for_permission)
      end

      should 'ask for permission to collaborate' do
        assert_difference('TransactableCollaborator.count') do
          post :create, transactable_id: @transactable.id, format: :json
        end

        transactable_collaborator = @transactable.reload.transactable_collaborators.last
        assert_not_nil transactable_collaborator.approved_by_user_at
        assert_nil transactable_collaborator.approved_by_owner_at
        assert_equal @user_who_asks_for_permission.id, transactable_collaborator.user_id

        # do not duplicate
        assert_raise ActiveRecord::RecordInvalid do
          post :create, transactable_id: @transactable.id, format: :json
        end
      end
    end

  end

  context 'accept' do

    setup do
      @transactable_collaborator = FactoryGirl.create(:transactable_collaborator)
    end

    context 'creator of the listing' do

      setup do
        set_authentication_header(@transactable_collaborator.transactable.creator)
      end

      should 'accept request by id' do
        put :accept, transactable_id: @transactable_collaborator.transactable_id, id: @transactable_collaborator.id, format: :json
        assert_not_nil @transactable_collaborator.reload.approved_by_owner_at
        assert_nil @transactable_collaborator.reload.approved_by_user_at
      end

    end

    context 'not a creator of the listing' do

      setup do
        set_authentication_header(@transactable_collaborator.user)
      end

      should 'accept request by id' do
        put :accept, transactable_id: @transactable_collaborator.transactable_id, id: @transactable_collaborator.id, format: :json
        @transactable_collaborator.reload
        assert_nil @transactable_collaborator.approved_by_owner_at
        assert_not_nil @transactable_collaborator.approved_by_user_at
      end
    end

  end

  context 'destroy' do

    setup do
      @transactable_collaborator = FactoryGirl.create(:transactable_collaborator)
    end

    context 'creator of the listing' do

      setup do
        set_authentication_header(@transactable_collaborator.transactable.creator)
      end

      should 'reject user' do
        assert_difference 'TransactableCollaborator.count', -1 do
          delete :destroy, transactable_id: @transactable_collaborator.transactable_id, id: @transactable_collaborator.id, format: :json
        end
      end

    end

    context 'not a creator of the listing' do

      setup do
        set_authentication_header(@transactable_collaborator.user)
      end

      should 'quit collaboration' do
        assert_difference 'TransactableCollaborator.count', -1 do
          delete :destroy, transactable_id: @transactable_collaborator.transactable_id, id: @transactable_collaborator.id, format: :json
        end
      end

    end

    context 'random user' do

      should 'not take any effect' do
        set_authentication_header(FactoryGirl.create(:user))
        assert_raise 'ActiveRecord::NotFound' do
          delete :destroy, transactable_id: @transactable_collaborator.transactable_id, id: @transactable_collaborator.id, format: :json
        end
      end
    end

  end

end

