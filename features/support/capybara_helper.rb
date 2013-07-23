module CapybaraHelper
  def wait_for_ajax
    wait_until(30) {
      page.evaluate_script('jQuery.active') == 0
    }
  end
end

World(CapybaraHelper)
