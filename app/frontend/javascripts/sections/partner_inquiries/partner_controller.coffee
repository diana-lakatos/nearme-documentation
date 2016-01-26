module.exports = class PartnerController

  constructor: (@container) ->
    @bindEvents()
    setTimeout( =>
      @setTestimonialsSecondColumnHeight()
    , 500)

  bindEvents: ->
    $(window).resize =>
      @setTestimonialsSecondColumnHeight()

    @container.find('.get-started form').submit (e) =>
      e.preventDefault()
      form = @container.find('.get-started form')
      form_valid = true
      form.find('.controls input').each ->
        if $(this).val() == ''
          $(this).effect("highlight", { color: 'rgb(231, 50, 66)' })
          form_valid = false

      if form_valid
        submit_button = form.find('input[type="submit"]')
        $.ajax
          type: 'POST'
          url: form.attr('action')
          data: form.serialize()
          beforeSend: () ->
            submit_button.prop('disabled', true).val(submit_button.data('disabled-text'))
          success: (response) ->
            submit_button.prop('disabled', false).val(submit_button.data('original-text'))
            if response.status
              form.replaceWith($('<div class="thanks">' + response.body + '</div>'))
            else
              form.find('.validation-fail').html(response.body)
          dataType: 'json'


  setTestimonialsSecondColumnHeight: ->
    if @container.find('.testimonials .span7').css('float') == 'left'
      first_column_height = parseInt(@container.find('.testimonials .span7').height())
      @container.find('.testimonials .span5 .white-box').height(first_column_height - 58)
    else
      @container.find('.testimonials .span5 .white-box').height('auto')
