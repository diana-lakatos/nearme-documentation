module ModalHelper
  def wait_modal_loaded
    page.has_selector?(".modal-overlay.visible")
    page.has_selector?(".modal-content.visible") # necessary ?
    sleep(0.25)
  end

  def wait_modal_closed
    page.has_no_selector?(".modal-content.visible")
    page.has_no_selector?(".modal-overlay.visible") # necessary ?
    sleep(0.25)
  end

  def work_in_modal
    wait_modal_loaded
    yield
    wait_modal_closed
  end
end

World(ModalHelper)
