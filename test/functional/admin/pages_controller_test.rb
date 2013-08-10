require 'test_helper'

class Admin::PagesControllerTest < ActionController::TestCase

  logged_in do
    context "No pages" do

      should "return blank form" do

        get :new

        assert_response :success
      end

      should "create page" do
        assert_difference('Page.count') do
          post :create, :page => attributes_for_page
        end

        page = Page.find_by_path(attributes_for_page['path'])
        assert_redirected_to admin_page_path(page)
        assert_equal attributes_for_page['path'], page.path
        assert_equal attributes_for_page['content'], page.content
        assert_equal Instance.default_instance.id, page.instance_id
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
        assert_redirected_to admin_page_path(@page)
        assert_equal @attributes_for_page['path'], @page.path
        assert_equal @attributes_for_page['content'], @page.content
        assert_equal Instance.default_instance.id, @page.instance_id
      end

      should "destroy page" do
        assert_difference "Page.count", -1 do
          delete :destroy, :id => @page.id
        end

        assert_redirected_to admin_pages_path
      end

    end
  end

  private
  def attributes_for_page
    @attributes_for_page ||= FactoryGirl.build(:page).attributes.slice('path', 'content', 'instance_id')
  end

end
