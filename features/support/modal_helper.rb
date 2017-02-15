module ModalHelper
  def wait_modal_loaded(overlay_class)
    page.should have_css(overlay_class)
  end

  def wait_modal_closed(overlay_class)
    page.should_not have_css(overlay_class)
  end

  def work_in_modal(overlay_class = '.modal-overlay.visible')
    wait_modal_loaded(overlay_class)
    yield
    wait_modal_closed(overlay_class)
  end
end

World(ModalHelper)
