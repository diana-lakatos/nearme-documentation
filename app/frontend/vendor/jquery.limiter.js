(function() {
  $.fn.extend({
    limiter: function(limit, elem) {
      $(this).on("keyup focus", function() {
        setCount(this, elem);
      });
      function setCount(src, elem) {
        var chars = src.value.length;
        if (chars > limit) {
          src.value = src.value.substr(0, limit);
          chars = limit;
        }
        var left = limit - chars;
        var word;
        if(left  == 1) {
          word = '1 character left';
        } else {
          word = left + ' characters left';
        };
        elem.html( word );
      }
      setCount($(this)[0], elem);
    }
  });
})(jQuery);
