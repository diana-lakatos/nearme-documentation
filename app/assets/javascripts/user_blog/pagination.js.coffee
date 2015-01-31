jQuery ->
  if $('#infinite-scrolling').size() > 0
    $(window).on 'scroll', ->
      next_page_path = $('.pagination .next_page').attr('href')
      if next_page_path && $(window).scrollTop() > $(document).height() - $(window).height() - 60
        $('.pagination').html('<img id="spinner" src="/assets/spinner.gif" alt="Loading ..." title="Loading ..." />')
        $.getScript next_page_path

      return

