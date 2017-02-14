module ModalHelper
  def wait_modal_loaded(overlay_class)
    begin
      page.has_selector?(overlay_class)
    rescue Capybara::Webkit::InvalidResponseError => e
      puts e.inspect
      #screenshot_and_open_image
    end
  end

  def wait_modal_closed(overlay_class)
    begin
      page.has_no_selector?(overlay_class)
    rescue Capybara::Webkit::InvalidResponseError => e
      puts e.inspect
      #screenshot_and_open_image
    end
  end

  def work_in_modal(overlay_class = '.modal-overlay.visible')
    wait_modal_loaded(overlay_class)
    yield
    wait_modal_closed(overlay_class)
  end
end

World(ModalHelper)
