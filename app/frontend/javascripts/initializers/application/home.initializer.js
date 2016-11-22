let hero = document.getElementById('hero');

if (hero) {
  require.ensure('../../sections/home/controller', (require)=>{
    const HomeController = require('../../sections/home/controller');
    return new HomeController(hero);
  }) ;
}

var els = $('form.search-box');

if (els.length > 0) {
  require.ensure('../../sections/search/home_controller', (require)=>{
    var SearchHomeController = require('../../sections/search/home_controller');

    els.each(function(){
      return new SearchHomeController(this);
    });
  });
}

$(document).on('init:homepageranges.nearme', function() {
  $('[name="start_date"]').each(function(index, element) {
    if($(element).datepicker && !$(element).attr('data-no-default')) {
      $(element).datepicker('setDate', new Date());
    }
  });

  $('[name="end_date"]').each(function(index, element) {
    if($(element).datepicker && !$(element).attr('data-no-default')) {
      $(element).datepicker('setDate', 1);
    }
  });
});
