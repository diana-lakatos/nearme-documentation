require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  context '#current_instance' do

    should 'trigger find_domain' do
      @controller.expects(:current_domain).once
      @controller.send(:current_instance)
    end

  end

end

