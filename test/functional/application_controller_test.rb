require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  context '#current_instance' do

    should 'trigger find_by_request' do
      Instance.stubs(:find_for_request).once
      @controller.send(:current_instance)
    end

  end

end

