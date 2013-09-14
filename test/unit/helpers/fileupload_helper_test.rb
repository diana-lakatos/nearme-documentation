require 'test_helper'
require 'action_view/test_case'


class FileuploadHelperTest < ActionView::TestCase
  context "#file_upload_input" do
    context "with required option" do
      should "include asterisk" do
        abbr_tag = "<abbr title='required'>*</abbr>"
        output = file_upload_input_with_label('Photos', 'test', 'name', {:width => 10, :height => 10}, 'Photos', :required => true)

        assert_match(/#{Regexp.escape(abbr_tag)}/, output)
      end
    end

    context "with error option" do
      should "include error message" do
        error_message = "upload photo please"
        error_block_tag = "<p class='error-block'>#{error_message}</p>"
        output = file_upload_input_with_label('Photos', 'test', 'name', { :width => 10, :height => 10}, 'Photos', :required => true, :error => error_message)

        assert_match(/#{Regexp.escape(error_block_tag)}/, output)
      end
    end
  end
end
