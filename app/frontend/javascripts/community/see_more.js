var SeeMore;

SeeMore = function() {
  function SeeMore() {
    this.bindEvents();
  }

  SeeMore.prototype.bindEvents = function() {
    $('form.sort-form').on('change', function(e) {
      return $(e.target).submit();
    });
    return $('[data-see-more] button').on('click', function(event) {
      var $button, moreUrl, nextPage, sortType;
      event.preventDefault();
      $button = $(event.target);
      nextPage = $button.data('next-page');
      moreUrl = $button.data('url');
      sortType = $button.closest('.tab-pane').find('form.sort-form select[name="[sort]"]').val();
      if (/page=/i.test(moreUrl)) {
        moreUrl = moreUrl.replace(/page=\d/, 'page=' + nextPage);
      } else {
        moreUrl = moreUrl + ('&page=' + nextPage);
      }
      if (/sort=/i.test(moreUrl)) {
        moreUrl = moreUrl.replace(/sort=[\w ]*/, 'sort=' + sortType);
      } else {
        moreUrl = moreUrl + ('&sort=' + sortType);
      }
      return $.get(moreUrl);
    });
  };

  return SeeMore;
}();

module.exports = SeeMore;
