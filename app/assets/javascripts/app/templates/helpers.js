(function() {
  function checkbox ( value, options ) {
    var $el = $('<div />').html( options.fn(this) );
    $el.find('[value=' + value + ']').attr({'checked':'checked'});
    return $el.html();
  }
  Handlebars.registerHelper( 'checkbox', checkbox );

  function multicheckbox ( values, options ) {
    var $el = $('<div />').html( options.fn(this) );
    _.each(values, function(value){
      $el.find('[value=' + value + ']').attr({'checked':'checked'});
    });
    return $el.html();
  }
  Handlebars.registerHelper( 'multicheckbox', multicheckbox );

  function debug(optionalValue) {
    console.log("Current Context");
    console.log("====================");
    console.log(this);
    if (optionalValue) {
      console.log("Value");
      console.log("====================");
      console.log(optionalValue);
    }
  }
  Handlebars.registerHelper('debug', debug);

  function compare ( lvalue, operator, rvalue, options  ) {
    var operators, result;

    if (arguments.length < 3) {
        throw new Error("Handlerbars Helper 'compare' needs 2 parameters");
    }

    if (options === undefined) {
        options = rvalue;
        rvalue = operator;
        operator = "===";
    }

    operators = {
        '==': function (l, r) { return l == r; },
        '===': function (l, r) { return l === r; },
        '!=': function (l, r) { return l != r; },
        '!==': function (l, r) { return l !== r; },
        '<': function (l, r) { return l < r; },
        '>': function (l, r) { return l > r; },
        '<=': function (l, r) { return l <= r; },
        '>=': function (l, r) { return l >= r; },
        'typeof': function (l, r) { return typeof l == r; }
    };

    if (!operators[operator]) {
        throw new Error("Handlerbars Helper 'compare' doesn't know the operator " + operator);
    }

    result = operators[operator](lvalue, rvalue);

    if (result) {
      return options.fn(this);
    } else {
      return options.inverse(this);
    }
  }
  Handlebars.registerHelper('compare', compare);

  function select(value, options) {
    var $el = $('<select />').html( options.fn(this) );
    $el.find('[value="' + value + '"]').attr({'selected':'selected'});
    return $el.html();
  }
  Handlebars.registerHelper( 'select', select );

  function shorten(text) {
    return (text.length > 10)? text.substr(0,7) + "..." : text;
  }
  Handlebars.registerHelper( 'shorten', shorten );
})()
