class @UserReviews
  constructor: (@container) ->
    @bindEvents()

  bindEvents: ->
    reviewsDropdown = @container.find('[data-reviews-dropdown]')

    reviewsDropdown.find('li').click () ->
      reviewsDropdown.find('[data-title]').text($(@).text())
      $.ajax
        url: reviewsDropdown.data('url')
        method: 'GET'
        data:
          option: $(@).data('option')
        success: (data) ->
          $('[data-reviews-count]').text(data.count)
          $('[data-reviews-content]').html(data.template)

    if @container.find('[data-sorting-reviews]').length
      reviewsDropdown.find('li:first').click()
         