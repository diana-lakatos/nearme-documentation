module AjaxHelper
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        active = page.evaluate_script('window.jQuery ? jQuery.active : 0')
        break if active.blank? || active == 0
        sleep 0.01
      end
    end
  end

  def wait_for_stripe
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        active = page.evaluate_script('window.Stripe ? 1 : 0')
        break if active == 1
        sleep 0.01
      end
    end
  end
end

World(AjaxHelper)
