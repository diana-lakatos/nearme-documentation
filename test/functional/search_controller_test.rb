require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test "it doesnt explode" do
    begin
    get :index, {"q"=>"Cleveland, OH", "lat"=>"", "lng"=>"", "nx"=>"", "ny"=>"", "sx"=>"", "sy"=>""}
    rescue
      require 'debugger'; debugger
      p $!
    end
  end

end
