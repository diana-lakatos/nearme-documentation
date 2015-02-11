jQuery.fn.advancedClosest = function(selector) {
  var result = jQuery([]);

  if(jQuery(this).is(selector)) {
    result = jQuery(this);
  } else if(jQuery(this).find(selector).length > 0) {
    result = jQuery(jQuery(this).find(selector).get(0));
  } else {
    jQuery(this).parents().each(function() {
      if(jQuery(this).is(selector)) {
        result = jQuery(this);

        return false;
      } else if(jQuery(this).find(selector).length > 0) {
        result = jQuery(jQuery(this).find(selector).get(0));

        return false;
      } else {
        return true;
      }   
    }); 
  }   

  return result;
}
