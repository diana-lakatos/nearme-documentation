//Help Bar
$(".help-bar-content").hide();

$("#toggle-help").click(function() {

  var helpBar = $("#help-bar");

  if (helpBar.hasClass("closed")) {
    helpBar.animate( {
      right: "0px"
    }, 400)

    helpBar.attr("class", "open")
      $(".help-bar-content").show();
    $("#toggle-help").attr("class", "fa fa-long-arrow-right")
  }

  else {
    helpBar.animate( {
      right: "-316px"
    }, 400, function() {
      $(".help-bar-content").hide();
    })

    helpBar.attr("class", "closed")
    $("#toggle-help").attr("class", "fa fa-long-arrow-left")
  }
});



$(function () {
  $(".line-item-btn").popover();
  var icui = $("input[type=hidden].icui").icui();
});



//Reveal input when user clicks 'add new'
$('.add-new-hidden').hide();

$('.add-new-btn').click(function() {
  $('.add-new-hidden').slideDown();
});



//Display file name on upload
$('.upload-file').change(function() {
  $('#' + $(this).attr('name')).append($(this).val().split('\\').pop());
});



//Prefences Checkbox slide
$(".cancellation-settings").hide();
$(".password-settings").hide();

$("#cancellation-check").change(function() {
  if($(this).is(':checked')) {
    $(".cancellation-settings").slideDown();
  }
  else {
    $(".cancellation-settings").slideUp();
  }
})

$("#password-check").change(function() {
  if($(this).is(':checked')) {
    $(".password-settings").slideDown();
  }
  else {
    $(".password-settings").slideUp();
  }
})



//Charts
// var randomScalingFactor = function(){ return Math.round(Math.random()*100)};
//     var lineChartData = {
//       labels : ["January","February","March","April","May","June","July"],
//       datasets : [
//         {
//           label: "My First dataset",
//           fillColor : "rgba(220,220,220,0.2)",
//           strokeColor : "rgba(220,220,220,1)",
//           pointColor : "rgba(220,220,220,1)",
//           pointStrokeColor : "#fff",
//           pointHighlightFill : "#fff",
//           pointHighlightStroke : "rgba(220,220,220,1)",
//           data : [randomScalingFactor(),randomScalingFactor(),randomScalingFactor(),randomScalingFactor(),randomScalingFactor(),randomScalingFactor(),randomScalingFactor()]
//         },
//       ]

//     }

//   window.onload = function(){
//     var ctxRevenue = document.getElementById("revenue").getContext("2d");
//     window.myLine = new Chart(ctxRevenue).Line(lineChartData, {
//       responsive: true
//     });
//     var ctxBookings = document.getElementById("bookings").getContext("2d");
//     window.myLine = new Chart(ctxBookings).Line(lineChartData, {
//       responsive: true
//     });
//     var ctxListings = document.getElementById("listings").getContext("2d");
//     window.myLine = new Chart(ctxListings).Line(lineChartData, {
//       responsive: true
//     });
//   }

//ColorPicker
$('.color-picker').click(function() {
  $('.color-picker').colpick({
    layout: 'rgbhex',
    submit: 0,
    onChange: function(hsb, hex, rgb, el, bySetColor) {
      $(el).children('.color-thumbnail').css('background-color', '#' + hex);
      if(!bySetColor) $(el).children('.color-select').val(hex);
      }
    }).keyup(function() {
      $(this).colpickSetColor(this.value);
  });
})

$('.selectpicker').selectpicker();

