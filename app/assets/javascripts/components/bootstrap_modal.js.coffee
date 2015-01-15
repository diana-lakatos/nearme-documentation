class @BootstrapModal
  # Listen for click events on modalized links
  # Modalized links are anchor elements with rel="modal"
  # A custom class can be specified on the modal:
  #   <a href="modalurl" rel="bootstrap_modal.my-class">link</a>
  @listen : ->
    $('body').delegate 'a[rel^="bootstrap_modal"]', 'click', (e) =>
      e.preventDefault()
      target = $(e.currentTarget)
      ajaxOptions = { url: target.attr("href"), data: target.data() }

      @modal = $("#bootstrap-modal")
      @modal_body = @modal.find(".modal-body")
      @modal_body.html("")
      @modal.modal("show")
      @load(ajaxOptions)

      false

  # Load the given URL in the modal
  # Displays the modal, shows the loading status, fires an AJAX request and
  # displays the content
  @load : (ajaxOptions) ->
    request = $.ajax(ajaxOptions)
    request.success (data) =>
      if data.redirect
        document.location = data.redirect
      else if data.hide
        @content.html('')
        @hide()
      else
        @modal_body.html(data)
