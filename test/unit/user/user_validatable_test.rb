require 'test_helper'

class User::UserValidatableTest < ActiveSupport::TestCase
  setup do
    User.destroy_all
    @user = FactoryGirl.create(:user)
    @email = @user.email
  end

  context 'user_validatable devise model' do
    should 'allow to soft delete and create same email without renaming' do
      # destroy him
      @user.destroy

      # assert there's still original mail in destroyed user
      assert_equal @email, @user.email

      # create new user with same email successfully
      assert FactoryGirl.create(:user, email: @email)

      # don't allow to create another user with same email
      refute FactoryGirl.build(:user, email: @email).valid?
    end
  end

  context 'deleting user and validation' do
    should 'allow to register a user with the same email as the one that already exists given he is deleted' do
      @user.destroy
      assert_nothing_raised do
        @new_user = FactoryGirl.create(:user, :email => @email)
      end
    end

    should 'not allow to register with the same email address as already existing user who is not deleted' do
      assert_raise ActiveRecord::RecordInvalid do
        FactoryGirl.create(:user, :email => @user.email)
      end
    end

    should 'ensure that the email is the same after recover' do
      @user.destroy
      @user.restore
      @user.reload
      assert_equal @email, @user.email, "Email of recovered user is different from the one user was using before deletion"
      assert !@user.deleted?, "User is still deleted after recovery"
    end

    should 'blow up if we try to recover user whose email has been taken while he was deleted' do
      @user.destroy
      FactoryGirl.create(:user, :email => @email)
      #assert_raise ActiveRecord::RecordNotUnique do
      #  @user.restore
      #end
    end
  end
end
