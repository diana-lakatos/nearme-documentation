class Reviews.Controller
  constructor: (@container, @review_options = {}) ->
    @path = @review_options.path
    @tab_header = @container.find('ul[data-tab-header]')
    @tab_content = @container.find('div[data-tab-content]')
    for object, reviewable_parent of @review_options.reviewables
      $.get(@path, {object: object, reviewable_parent_type: reviewable_parent.type, reviewable_parent_id: reviewable_parent.id, subject: reviewable_parent.subject}, (response) =>
        if response.tab_header != ''
          @tab_header.append(response.tab_header)
          tab_content = $(response.tab_content)
          @listenForPagination(tab_content)
          @tab_content.append(tab_content)
      )

  listenForPagination: (tab_content) ->
    tab_content.find('.pagination a').on('click', (e) =>
      e.preventDefault()
      href = $(e.target).closest('a').attr('href')
      if href
        tab_content.html('Loading...')
        $.get(href, (response) =>
          new_tab_content = $(response.tab_content)
          tab_content.html(new_tab_content)
          @listenForPagination(tab_content)
        )
    )



