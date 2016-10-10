require 'test_helper'

class AttachmentsHelperTest < ActionView::TestCase
  setup do
    @user = FactoryGirl.create(:user, instance: FactoryGirl.create(:instance))
    @free_attachments = [
      FactoryGirl.create(:seller_attachment, user: @user, assetable: nil),
      FactoryGirl.create(:seller_attachment, user: @user, assetable: nil)
    ]

    @other_attachment   = FactoryGirl.create(:seller_attachment, user: @user, assetable: FactoryGirl.create(:transactable, creator: @user))
  end

  def current_user
    @user
  end

  should 'return free attachment ids for new transactable' do
    transactable = FactoryGirl.build(:transactable, creator: @user)
    params[:attachment_ids] = @free_attachments.map(&:id) + [987, 1024]
    assert_equal(@free_attachments.map(&:id).sort, attachment_ids_for(transactable).sort)
  end

  should 'return free and existing attachment ids for existing transactable' do
    transactable = FactoryGirl.create(:transactable, creator: @user)
    attachment = FactoryGirl.create(:seller_attachment, user: @user, assetable: transactable)
    params[:attachment_ids] = @free_attachments.map(&:id) + [attachment.id] + [987, 1024]
    assert_equal((@free_attachments.map(&:id) + [attachment.id]).sort, attachment_ids_for(transactable).sort)
  end

  should 'not return attachment ids for other transactables' do
    transactable = FactoryGirl.create(:transactable, creator: @user)
    attachment = FactoryGirl.create(:seller_attachment, user: @user, assetable: transactable)
    params[:attachment_ids] = @free_attachments.map(&:id) + [attachment.id, @other_attachment.id] + [987, 1024]
    refute_includes(attachment_ids_for(transactable), @other_attachment.id)
  end
end
