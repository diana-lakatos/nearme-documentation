module.exports = class MessagesController

  constructor: (container) ->
    @container = $(container)
    @form = @container.find('form')
    @message_field = @form.find('[data-message-body]')
    @message_field_group = @message_field.closest('.form-group')
    @submit_button = @form.find('[type=submit]')
    @thread = $('.inbox-thread')
    @errors = []
    @bindEvents()

  validate: =>
    flag = true
    message = @message_field.val()

    if $.trim(message) == ''
      flag = false
      @message_field_group.addClass('has-error')
      @message_field_group.append('<span class="help-block">Message can’t be blank</span>')

    return flag

  resetValidationUI: =>
    @form.find('span.help-block').remove()
    @form.find('.form-group.has-error').removeClass('has-error')

  bindEvents: ->
    @form.on 'submit', (e) =>
      @resetValidationUI()
      is_valid = @validate()
      return is_valid

    @form.on 'ajax:beforeSend', (e, xhr, settings) =>
      @submit_button.attr('disabled', 'disabled').val('Sending...')

    @form.on 'ajax:success', (e, data, status, xhr) =>
      @thread.append(data)

    @form.on 'ajax:complete', (e, xhr, status) =>
      @submit_button.removeAttr('disabled').val('Send')
      @message_field.val('')
