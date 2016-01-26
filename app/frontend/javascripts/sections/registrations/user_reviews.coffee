module.exports = class UserReviews
  constructor: (@container) ->
    @loadingContainer = @container.find('[data-loading]')
    @contentContainer = $('[data-reviews-content]')
    @countContainer = $('[data-reviews-count]')
    @reviewsDropdown = @container.find('[data-reviews-dropdown]')
    @bindEvents()

  bindEvents: ->

    @reviewsDropdown.find('li').click (event) =>

      @reviewsDropdown.find('[data-title]').text($(event.target).text())
      @contentContainer.hide()
      @loadingContainer.show()
      $.ajax
        url: @reviewsDropdown.data('url')
        method: 'GET'
        data:
          option: $(event.target).data('option')
        success: (data) =>
          @countContainer.text(data.count)
          @contentContainer.html(data.template)
          @contentContainer.show()
          @loadingContainer.hide()
          paginationInit()

    if @container.find('[data-sorting-reviews]').length
      @reviewsDropdown.find('li:first').click()

    paginationInit = (template) =>
      @reviewsPagination = $('[data-reviews-content]').find('.pagination')

      @reviewsPagination.find('li a').click (event) =>
        @contentContainer.hide()
        @loadingContainer.show()
        $.ajax
          url: $(event.target).attr('href') || $(event.target).parent().attr('href')
          method: 'GET'
          success: (data) =>
            @contentContainer.html(data.template)
            @loadingContainer.hide()
            @contentContainer.show()
            paginationInit()
        false
