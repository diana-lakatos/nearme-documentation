module ModalHelper
  def wait_modal_loaded(modal_selector)
    begin
      opacity = page.evaluate_script("$('#{modal_selector}').css('opacity');")
    end while opacity != '1'
  end
end

World(ModalHelper)
