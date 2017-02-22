require 'test_helper'

class DocumentsUploadTest < ActiveSupport::TestCase
  should belong_to(:instance)

  should validate_presence_of(:requirement)

  context '#is_enabled?' do
    setup do
      @documents_upload = FactoryGirl.create(:documents_upload)
    end

    should 'return true' do
      documents_upload = FactoryGirl.create(:enabled_documents_upload)

      assert documents_upload.is_enabled?
    end

    should 'return false' do
      refute @documents_upload.is_enabled?
    end

    should 'return true with errors' do
      @documents_upload.requirement = ''
      @documents_upload.save

      assert @documents_upload.is_enabled?
    end
  end
end
