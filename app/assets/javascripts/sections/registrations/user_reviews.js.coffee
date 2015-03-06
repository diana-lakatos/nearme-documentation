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
          paginationInit()

    if @container.find('[data-sorting-reviews]').length
      reviewsDropdown.find('li:first').click()

    paginationInit = (template) ->
      reviewsPagination = $('[data-reviews-content]').find('.pagination')

      reviewsPagination.find('li a').click () ->
        $.ajax
          url: $(this).attr('href')
          method: 'GET'
          success: (data) ->
            $('[data-reviews-content]').html(data.template)
            paginationInit()
        false
