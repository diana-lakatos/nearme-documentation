module ModalHelper
  def wait_modal_loaded
    begin
      page.has_selector?(".modal-overlay.visible")
    rescue Capybara::Webkit::InvalidResponseError => e
      puts e.inspect
      #screenshot_and_open_image
    end
  end

  def wait_modal_closed
    begin
      page.has_no_selector?(".modal-content.visible")
    rescue Capybara::Webkit::InvalidResponseError => e
      puts e.inspect
      #screenshot_and_open_image
    end
  end

  def work_in_modal
    wait_modal_loaded
    yield
    wait_modal_closed
  end
end

World(ModalHelper)
