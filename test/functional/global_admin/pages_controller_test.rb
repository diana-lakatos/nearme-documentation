require 'test_helper'

class GlobalAdmin::PagesControllerTest < ActionController::TestCase

  logged_in do
    context "No pages" do

      should "return blank form" do

        get :new

        assert_response :success
      end

    end

    context "Existing page" do

      setup do
        @page = FactoryGirl.create(:page)
      end

      should "get edit form" do
        get :edit, id: @page.id

        assert_response :success
      end

      should "update page" do
        put :update, :id => @page.id, :page => attributes_for_page

        @page.reload
        assert_redirected_to global_admin_page_path(@page)
        assert_equal @attributes_for_page['path'], @page.path
        assert_equal @attributes_for_page['content'], @page.content
        assert_equal Instance.first.theme.id, @page.theme_id
      end

      should "destroy page" do
        assert_difference "Page.count", -1 do
          delete :destroy, :id => @page.id
        end

        assert_redirected_to global_admin_pages_path
      end

    end
  end

  private
  def attributes_for_page
    @attributes_for_page ||= FactoryGirl.build(:page).attributes.slice('path', 'content', 'theme_id')
  end

end
