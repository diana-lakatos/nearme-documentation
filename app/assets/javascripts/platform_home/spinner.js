function pathFind(from, to) {
  if(Math.abs(from - to) > 180) {
    if(from < to && to > 180) {
      if(from == 0) from = 360;
      if(from == 60 && to == 300) from = 420;
      if(from == 60 && to == 360) to = 0;
      if(from == 120 && to == 360) to = 0;
    } else if(from > to && to < 180) {
      if(to == 0) to = 360;
      if(from == 300 && to == 60) to = 420;
      if(from == 360 && to == 60) from = 0;
      if(from == 360 && to == 120) from = 0;
    };
  };
  return {from: from, to: to};
};

function Spinner(element) {
  this.element = element;
  this.parts = 6;
  this.step = 360 / this.parts;
  this.position = 360;
  this.setPosition = function(position) {
    if(position == 420) position = 60;
    if(position == 0) position = 360;
    this.position = position;
  };
  this.moveTo = function(position) {
    result = pathFind(this.position, position);
    if(this.position != position) $(document).trigger('spinner:move', result);
  };
  this.rotate = function() {
    var newPosition = this.position - this.step;
    if(newPosition == 0) newPosition = newPosition + 360;
    this.moveTo(newPosition);
  };
};

var removeStepDone;
var addStepDone;

function SpinnerController(spinner) {
  this.element = spinner.element;
  this.spinner = spinner;
  this.animationRunning = false;

  this.initialize = function() {
    var self = this;
    $(document).on('spinner:move', function(e, position) {
      self.spinner.setPosition(position.to);
      $({deg: position.from}).animate({deg: position.to}, {
        start: function() {removeStepDone = false; addStepDone = false; self.animationRunning = true;},
        done: function() {self.animationRunning = false},
        duration: $('.wheel').is(':visible') ? (Math.abs(position.from - position.to) / self.spinner.step) * 1000 : 0,
        step: function(now) {
          $('.ico').css({
            transform: 'rotate(-' + now + 'deg)'
          });

          self.element.css({
            transform: 'rotate(' + now + 'deg)'
          });

          var nowInt = parseInt(now);
          var actionStep = 20;

          if(Math.abs(nowInt - position.from) >= actionStep && removeStepDone == false) {
            $('.ico').removeClass('active');
            $('.boxes .box').addClass('hidden');
            $('.boxes .box[data-for="' + self.spinner.position + '"]').removeClass('hidden');
            removeStepDone = true;
          };

          if(Math.abs(nowInt - position.to) <= actionStep && addStepDone == false) {
            $('.ico[data-position="' + self.spinner.position +'"]').addClass('active');
            addStepDone = true;
          };
        }
      });
    });
  };

  this.initialize();
};

var spinner, controller, interval;
$(document).ready(function() {
  // Spinner setup
  spinner = new Spinner($('#image'));
  controller = new SpinnerController(spinner);

  // Autorotate
  interval = setInterval(function() {spinner.rotate();}, 8000);

  // Bind spinner click actions
  $('.ico').on('click', function(e) {
    e.preventDefault();
    clearInterval(interval);

    if(!controller.animationRunning) {
      var position = parseInt($(this).data('position'));
      spinner.moveTo(position);
    };
  });

  // PassThrough hack
  function passThrough(e) {
      $(".ico").each(function() {
         // check if clicked point (taken from event) is inside element
         var mouseX = e.pageX;
         var mouseY = e.pageY;
         var offset = $(this).offset();
         var width = $(this).width();
         var height = $(this).height();

         if (mouseX > offset.left && mouseX < offset.left+width 
             && mouseY > offset.top && mouseY < offset.top+height)
           $(this).click(); // force click event
      });
  };

  $(document).on('click', passThrough);
});
