$(function(){
  $("#photos a:has(img), #photos [href$=.jpg], #photos a[href$=.png], #photos a[href$=.gif]")
    .attr("rel", "photos").fancybox({
      transitionIn: "elastic",
      transitionOut: "elastic",
      titlePosition: "over",
      padding: 0
    });
});