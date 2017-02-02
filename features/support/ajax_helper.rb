module AjaxHelper
  def wait_for_ajax
    Timeout.timeout(Capybara.default_wait_time) do
      loop do
        active = page.evaluate_script('window.jQuery ? jQuery.active : 0')
        break if active.blank? || active == 0
        sleep 0.01
      end
    end
  end
end

World(AjaxHelper)
